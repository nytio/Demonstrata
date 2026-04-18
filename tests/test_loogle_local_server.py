from __future__ import annotations

from pathlib import Path
from types import SimpleNamespace
from urllib.parse import urlparse

import pytest

from tools.loogle_local_server import LoogleRequestHandler, ServerConfig


class DummyHandler(LoogleRequestHandler):
    def __init__(self, server: object) -> None:
        self.server = server
        self.responses: list[tuple[int, dict[str, object]]] = []

    def _send_json(self, status: int, payload: dict[str, object]) -> None:
        self.responses.append((status, payload))


def test_server_config_from_env(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setenv("LOOGLE_LOCAL_HOST", "0.0.0.0")
    monkeypatch.setenv("LOOGLE_LOCAL_PORT", "9001")

    config = ServerConfig.from_env()

    assert config.host == "0.0.0.0"
    assert config.port == 9001
    assert config.wrapper_script.name == "loogle_local.sh"
    assert config.mathlib_index_path == (
        config.repo_root / ".local-tools" / "loogle-indexes" / "Mathlib.extra"
    )


def test_server_config_rejects_invalid_port(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    monkeypatch.setenv("LOOGLE_LOCAL_PORT", "not-a-port")

    with pytest.raises(ValueError, match="invalid LOOGLE_LOCAL_PORT"):
        ServerConfig.from_env()


def test_server_config_allows_mathlib_index_override(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    monkeypatch.setenv(
        "LOOGLE_LOCAL_MATHLIB_INDEX",
        "/custom/cache/Mathlib.extra",
    )

    config = ServerConfig.from_env()

    assert config.mathlib_index_path == Path("/custom/cache/Mathlib.extra")


def test_server_config_builds_explicit_mathlib_command(tmp_path: Path) -> None:
    repo_root = tmp_path / "repo"
    wrapper_script = repo_root / "scripts" / "loogle_local.sh"
    mathlib_index_path = repo_root / ".local-tools" / "loogle-indexes" / "Mathlib.extra"
    mathlib_index_path.parent.mkdir(parents=True)
    mathlib_index_path.write_text("index")
    config = ServerConfig(
        repo_root=repo_root,
        wrapper_script=wrapper_script,
        mathlib_index_path=mathlib_index_path,
        host="127.0.0.1",
        port=8088,
    )

    assert config.loogle_start_command() == [
        str(wrapper_script),
        "--module",
        "Mathlib",
        "--read-index",
        str(mathlib_index_path),
        "--json",
        "--interactive",
    ]


def test_request_handler_returns_query_payload() -> None:
    loogle_process = SimpleNamespace(
        query=lambda query: {"hits": [{"name": query}], "suggestions": []}
    )
    handler = DummyHandler(SimpleNamespace(loogle_process=loogle_process))

    handler._handle_json(urlparse("/json?q=Nat.add_comm"))

    assert handler.responses == [
        (200, {"hits": [{"name": "Nat.add_comm"}], "suggestions": []})
    ]


def test_request_handler_rejects_missing_query() -> None:
    loogle_process = SimpleNamespace(
        query=lambda query: {"hits": [], "suggestions": []}
    )
    handler = DummyHandler(SimpleNamespace(loogle_process=loogle_process))

    handler._handle_json(urlparse("/json"))

    assert handler.responses == [
        (400, {"error": "missing q parameter", "suggestions": []})
    ]


class BrokenWriter:
    def write(self, body: bytes) -> None:
        raise BrokenPipeError("client disconnected")


def test_request_handler_ignores_broken_pipe(
    caplog: pytest.LogCaptureFixture,
) -> None:
    handler = object.__new__(LoogleRequestHandler)
    handler.path = "/json?q=Nat.add_comm"
    handler.wfile = BrokenWriter()

    with caplog.at_level("INFO", logger="mimate.loogle_local_server"):
        handler._write_body(b'{"hits":[]}')

    assert "client disconnected before response body was fully written" in caplog.text
