#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
host="${LOOGLE_LOCAL_HOST:-127.0.0.1}"
port="${LOOGLE_LOCAL_PORT:-8088}"
server_url="http://${host}:${port}"
log_file="${TMPDIR:-/tmp}/mimate-loogle-local.log"

background=0
if [[ "${1:-}" == "--background" || "${1:-}" == "--bg" ]]; then
  background=1
  shift
fi

if [[ $# -ne 0 ]]; then
  echo "Usage: $0 [--background|--bg]" >&2
  exit 2
fi

log() {
  printf '[restart_loogle_local] %s\n' "$*" >&2
}

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

if probe_server >/dev/null 2>&1; then
  log "Stopping existing loogle server on ${server_url}"
  pkill -f 'tools/loogle_local_server.py' >/dev/null 2>&1 || true

  for _ in {1..20}; do
    if ! probe_server >/dev/null 2>&1; then
      break
    fi
    sleep 1
  done

  if probe_server >/dev/null 2>&1; then
    echo "Failed to stop the existing loogle server at ${server_url}" >&2
    exit 1
  fi
else
  log "No running loogle server detected on ${server_url}"
fi

if [[ "$background" -eq 1 ]]; then
  log "Starting loogle server in the background"
  log "Server log: $log_file"
  nohup "$repo_root/scripts/start_loogle_local_server.sh" >"$log_file" 2>&1 &
  if ! wait_for_server 20; then
    echo "Failed to start the loogle server in the background. Log: $log_file" >&2
    exit 1
  fi
  "$repo_root/scripts/check_loogle_local.sh"
  exit 0
fi

log "Restarting loogle server in the foreground"
exec "$repo_root/scripts/start_loogle_local_server.sh"
