#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
codex_bin="${CODEX_BIN:-codex}"
loogle_api_url="${LEANSEARCHCLIENT_LOOGLE_API_URL:-http://127.0.0.1:8088/json}"
mathlib_index_path="${LOOGLE_LOCAL_MATHLIB_INDEX:-$repo_root/.local-tools/loogle-indexes/Mathlib.extra}"

log() {
  printf '[init] %s\n' "$*" >&2
}

require_command() {
  local command_name="$1"
  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "Missing required command: $command_name" >&2
    exit 1
  fi
}

run_status_command() {
  local result_var="$1"
  local label="$2"
  shift 2
  log "$label"
  if "$@"; then
    printf -v "$result_var" '%s' "passed"
    return 0
  fi

  local status=$?
  printf -v "$result_var" '%s' "failed (exit ${status})"
  return 0
}

build_initial_prompt() {
  local loogle_status="$1"
  local build_status="$2"
  local test_status="$3"
  local mathlib_index_status="$4"
  local user_prompt="$5"

  cat <<EOF
El entorno del proyecto ya fue inicializado en ${repo_root}.

Estado actual:
- servicio loogle local: ${loogle_status}
- build estricto (\`scripts/build_strict.sh\`): ${build_status}
- tests Python (\`.venv/bin/python -m pytest -q\`): ${test_status}
- URL de LeanSearchClient para #loogle: ${loogle_api_url}
- indice persistido de Mathlib: ${mathlib_index_status}

Para consultas `Mathlib` sensibles a sandbox, prefiere:
\`scripts/loogle_local.sh --read-index ${mathlib_index_path} --module Mathlib '<query>'\`

Ese indice persistido de Mathlib solo se regenera cuando cambia la libreria `Mathlib`.

Consulta inicial:
${user_prompt}
EOF
}

main() {
  local build_status
  local test_status
  local loogle_status
  local mathlib_index_status
  local initial_prompt
  local user_prompt

  cd "$repo_root"

  require_command "$codex_bin"

  if [[ $# -gt 0 ]]; then
    user_prompt="$*"
  else
    user_prompt="Revisa el estado actual del repositorio, teniendo en cuenta el resultado del build y los tests, y continúa desde aquí."
  fi

  export LEANSEARCHCLIENT_LOOGLE_API_URL="$loogle_api_url"
  export LOOGLE_LOCAL_MATHLIB_INDEX="$mathlib_index_path"

  if [[ -f "$mathlib_index_path" ]]; then
    mathlib_index_status="available at ${mathlib_index_path}"
  else
    mathlib_index_status="missing at ${mathlib_index_path}"
  fi

  log "Restarting the local loogle service"
  "$repo_root/scripts/restart_loogle_local.sh" --background
  loogle_status="healthy (${loogle_api_url})"

  run_status_command \
    build_status \
    "Running strict Lean build" \
    "$repo_root/scripts/build_strict.sh"
  run_status_command \
    test_status \
    "Running Python test suite" \
    "$repo_root/.venv/bin/python" -m pytest -q

  initial_prompt="$(
    build_initial_prompt "$loogle_status" "$build_status" "$test_status" "$mathlib_index_status" "$user_prompt"
  )"

  log "Launching Codex with the initialized project context"
  exec "$codex_bin" "$initial_prompt"
}

main "$@"
