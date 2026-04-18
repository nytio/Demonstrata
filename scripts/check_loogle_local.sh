#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
loogle_src="$repo_root/.local-tools/loogle"
loogle_bin="$repo_root/.local-tools/loogle-mimate/.lake/build/bin/loogle"
mathlib_index_file="${LOOGLE_LOCAL_MATHLIB_INDEX:-$repo_root/.local-tools/loogle-indexes/Mathlib.extra}"
host="${LOOGLE_LOCAL_HOST:-127.0.0.1}"
port="${LOOGLE_LOCAL_PORT:-8088}"
server_url="http://${host}:${port}"
json_url="${server_url}/json"

log() {
  printf '[check_loogle_local] %s\n' "$*" >&2
}

want_start=0
if [[ "${1:-}" == "--start" ]]; then
  want_start=1
  shift
fi

if [[ $# -ne 0 ]]; then
  echo "Usage: $0 [--start]" >&2
  exit 2
fi

if [[ ! -d "$loogle_src" ]]; then
  echo "Missing upstream loogle source at $loogle_src" >&2
  echo "Bootstrap it first:" >&2
  echo "  git clone https://github.com/nomeata/loogle $loogle_src" >&2
  exit 1
fi

if [[ ! -x "$loogle_bin" ]]; then
  echo "Missing local loogle binary at $loogle_bin" >&2
  echo "Build it first:" >&2
  echo "  scripts/build_loogle_local.sh" >&2
  exit 1
fi

if [[ -f "$mathlib_index_file" ]]; then
  log "Persisted Mathlib index available at ${mathlib_index_file}"
else
  log "Persisted Mathlib index not found at ${mathlib_index_file}"
fi

probe_server() {
  curl --silent --show-error --fail "${server_url}/" >/dev/null
}

wait_for_server() {
  local max_seconds="$1"
  local elapsed=0

  while (( elapsed < max_seconds )); do
    if probe_server >/dev/null 2>&1; then
      return 0
    fi
    if (( elapsed == 0 || elapsed % 5 == 0 )); then
      log "Waiting for ${server_url}/ to answer (${elapsed}s elapsed)"
    fi
    sleep 1
    elapsed=$((elapsed + 1))
  done

  return 1
}

run_json_probe() {
  local response_file
  local curl_pid
  local elapsed=0

  response_file="$(mktemp "${TMPDIR:-/tmp}/mimate-loogle-response.XXXXXX")"
  trap 'rm -f "$response_file"' RETURN

  log "Querying ${json_url}?q=Nat.add_comm"
  log "The first query can take a while while loogle builds or warms its index"
  log "To avoid cold-start waits next time, prebuild the persisted Mathlib index with scripts/build_loogle_index.sh"

  curl --silent --show-error --fail "${json_url}?q=Nat.add_comm" >"$response_file" &
  curl_pid=$!

  while kill -0 "$curl_pid" >/dev/null 2>&1; do
    sleep 5
    elapsed=$((elapsed + 5))
    if kill -0 "$curl_pid" >/dev/null 2>&1; then
      log "Still waiting for JSON results (${elapsed}s elapsed)"
    fi
  done

  if ! wait "$curl_pid"; then
    local curl_status=$?
    log "JSON probe failed after ${elapsed}s"
    return "$curl_status"
  fi

  cat "$response_file"
  rm -f "$response_file"
  trap - RETURN
}

if ! probe_server >/dev/null 2>&1; then
  if [[ "$want_start" -eq 0 ]]; then
    echo "Local loogle server is not running at ${server_url}" >&2
    echo "Start it with:" >&2
    echo "  scripts/start_loogle_local_server.sh" >&2
    echo "Or let this script start it with:" >&2
    echo "  scripts/check_loogle_local.sh --start" >&2
    exit 1
  fi

  log_file="${TMPDIR:-/tmp}/mimate-loogle-local.log"
  log "Starting local loogle server in the background"
  log "Server log: $log_file"
  nohup "$repo_root/scripts/start_loogle_local_server.sh" >"$log_file" 2>&1 &
  server_pid=$!

  if ! wait_for_server 20; then
    echo "Failed to start local loogle server. Log: $log_file" >&2
    kill "$server_pid" >/dev/null 2>&1 || true
    exit 1
  fi
else
  log "Local loogle server already answers on ${server_url}"
fi

response="$(run_json_probe)"

.venv/bin/python - "$response" <<'PY'
from __future__ import annotations

import json
import sys

if len(sys.argv) != 2:
    raise SystemExit("expected loogle JSON payload as the first argument")

payload = json.loads(sys.argv[1])
if not isinstance(payload, dict):
    raise SystemExit("loogle response is not a JSON object")

hits = payload.get("hits")
if not isinstance(hits, list):
    raise SystemExit("loogle response does not contain a 'hits' list")

if not hits:
    raise SystemExit("loogle response contains no hits for Nat.add_comm")
PY

echo "Local loogle server is healthy at ${server_url}"
