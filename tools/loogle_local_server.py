#!/usr/bin/env python3
from __future__ import annotations

from dataclasses import dataclass
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
import json
import logging
import os
import subprocess
import threading
from urllib.parse import parse_qs, urlparse


LOGGER = logging.getLogger("demonstrata.loogle_local_server")


@dataclass(frozen=True)
class ServerConfig:
    repo_root: Path
    wrapper_script: Path
    mathlib_index_path: Path
    host: str
    port: int

    @classmethod
    def from_env(cls) -> "ServerConfig":
        repo_root = Path(__file__).resolve().parent.parent
        host = os.environ.get("LOOGLE_LOCAL_HOST", "127.0.0.1")
        port_text = os.environ.get("LOOGLE_LOCAL_PORT", "8088")
        mathlib_index_path = Path(
            os.environ.get(
                "LOOGLE_LOCAL_MATHLIB_INDEX",
                str(repo_root / ".local-tools" / "loogle-indexes" / "Mathlib.extra"),
            )
        )
        try:
            port = int(port_text)
        except ValueError as err:
            raise ValueError(f"invalid LOOGLE_LOCAL_PORT: {port_text}") from err
        return cls(
            repo_root=repo_root,
            wrapper_script=repo_root / "scripts" / "loogle_local.sh",
            mathlib_index_path=mathlib_index_path,
            host=host,
            port=port,
        )

    def loogle_start_command(self) -> list[str]:
        command = [str(self.wrapper_script), "--module", "Mathlib"]
        if self.mathlib_index_path.exists():
            command.extend(["--read-index", str(self.mathlib_index_path)])
        command.extend(["--json", "--interactive"])
        return command


class LoogleProcess:
    def __init__(self, config: ServerConfig) -> None:
        self._config = config
        self._lock = threading.Lock()
        self._process: subprocess.Popen[str] | None = None

    def query(self, query: str) -> dict[str, object]:
        with self._lock:
            process = self._ensure_started()
            try:
                return self._query_once(process, query)
            except Exception:
                self._stop()
                process = self._ensure_started()
                return self._query_once(process, query)

    def _ensure_started(self) -> subprocess.Popen[str]:
        if self._process is not None and self._process.poll() is None:
            return self._process
        command = self._config.loogle_start_command()
        if self._config.mathlib_index_path.exists():
            LOGGER.info(
                "starting local loogle process with persisted Mathlib index: %s",
                self._config.mathlib_index_path,
            )
        else:
            LOGGER.info(
                "starting local loogle process without persisted Mathlib index: %s",
                self._config.mathlib_index_path,
            )
        self._process = subprocess.Popen(
            command,
            cwd=self._config.repo_root,
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            encoding="utf-8",
        )
        assert self._process.stdout is not None
        greeting = self._process.stdout.readline()
        if greeting != "Loogle is ready.\n":
            stderr = ""
            if self._process.stderr is not None:
                stderr = self._process.stderr.read()
            self._stop()
            raise RuntimeError(
                f"loogle did not become ready; greeting={greeting!r}, stderr={stderr!r}"
            )
        return self._process

    def _query_once(
        self, process: subprocess.Popen[str], query: str
    ) -> dict[str, object]:
        if process.stdin is None or process.stdout is None:
            raise RuntimeError("loogle process stdio is not available")
        process.stdin.write(query)
        process.stdin.write("\n")
        process.stdin.flush()
        line = process.stdout.readline()
        if not line:
            stderr = ""
            if process.stderr is not None:
                stderr = process.stderr.read()
            raise RuntimeError(f"loogle returned no output; stderr={stderr!r}")
        try:
            payload = json.loads(line)
        except json.JSONDecodeError as err:
            raise RuntimeError(f"invalid loogle JSON: {line!r}") from err
        if not isinstance(payload, dict):
            raise RuntimeError(f"unexpected loogle payload: {payload!r}")
        return payload

    def _stop(self) -> None:
        if self._process is None:
            return
        if self._process.poll() is None:
            self._process.kill()
            self._process.wait(timeout=5)
        self._process = None


class LoogleRequestHandler(BaseHTTPRequestHandler):
    server_version = "DemonstrataLoogle/1.0"

    def do_GET(self) -> None:  # noqa: N802
        parsed = urlparse(self.path)
        if parsed.path == "/json":
            self._handle_json(parsed)
            return
        if parsed.path == "/":
            self._send_text(200, "Local loogle server is running.\n")
            return
        self._send_text(404, "Not found.\n")

    def log_message(self, format: str, *args: object) -> None:
        LOGGER.info("%s - %s", self.address_string(), format % args)

    def _handle_json(self, parsed_url) -> None:
        query_values = parse_qs(parsed_url.query).get("q", [])
        query = query_values[0] if query_values else ""
        if not query.strip():
            self._send_json(400, {"error": "missing q parameter", "suggestions": []})
            return
        try:
            payload = self.server.loogle_process.query(query)  # type: ignore[attr-defined]
        except Exception as err:
            LOGGER.exception("loogle query failed")
            self._send_json(500, {"error": str(err), "suggestions": []})
            return
        self._send_json(200, payload)

    def _send_json(self, status: int, payload: dict[str, object]) -> None:
        body = json.dumps(payload).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Access-Control-Allow-Origin", "*")
        self.end_headers()
        self._write_body(body)

    def _send_text(self, status: int, body: str) -> None:
        data = body.encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "text/plain; charset=utf-8")
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self._write_body(data)

    def _write_body(self, body: bytes) -> None:
        try:
            self.wfile.write(body)
        except (BrokenPipeError, ConnectionResetError):
            LOGGER.info(
                "client disconnected before response body was fully written: %s",
                self.path,
            )


class LoogleHTTPServer(ThreadingHTTPServer):
    def __init__(
        self,
        server_address: tuple[str, int],
        request_handler: type[BaseHTTPRequestHandler],
        loogle_process: LoogleProcess,
    ) -> None:
        super().__init__(server_address, request_handler)
        self.loogle_process = loogle_process


def main() -> None:
    logging.basicConfig(level=logging.INFO, format="%(levelname)s %(message)s")
    config = ServerConfig.from_env()
    if not config.wrapper_script.exists():
        raise FileNotFoundError(f"missing wrapper script: {config.wrapper_script}")
    loogle_process = LoogleProcess(config)
    server = LoogleHTTPServer(
        (config.host, config.port), LoogleRequestHandler, loogle_process
    )
    LOGGER.info("serving local loogle on http://%s:%d", config.host, config.port)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        LOGGER.info("shutting down local loogle server")
    finally:
        server.server_close()
        server.loogle_process._stop()


if __name__ == "__main__":
    main()
