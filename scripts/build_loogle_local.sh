#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
loogle_src="$repo_root/.local-tools/loogle"
loogle_ws="$repo_root/.local-tools/loogle-mimate"

if [[ ! -d "$loogle_src" ]]; then
  echo "Missing upstream loogle source at $loogle_src" >&2
  echo "Clone it first, for example:" >&2
  echo "  git clone https://github.com/nomeata/loogle $loogle_src" >&2
  exit 1
fi

mkdir -p "$repo_root/.local-tools"
rsync -a --delete --exclude '.git' --exclude '.lake' "$loogle_src/" "$loogle_ws/"

cat > "$loogle_ws/lean-toolchain" <<'EOF'
leanprover/lean4:v4.29.0
EOF

cat > "$loogle_ws/lakefile.lean" <<'EOF'
import Lake
open Lake DSL

package «loogle» {
  moreLinkArgs :=
   if run_io Option.isSome <$> IO.getEnv "LOOGLE_SECCOMP"
   then #[ "-lseccomp" ]
   else #[]
  testDriver := "Tests"
}

-- Pin every dependency to the copies already resolved in the main repository.
-- This keeps the loogle build aligned with the current workspace and avoids
-- fetching a separate dependency graph.
require mathlib from "../../.lake/packages/mathlib"
require plausible from "../../.lake/packages/plausible"
require LeanSearchClient from "../../.lake/packages/LeanSearchClient"
require importGraph from "../../.lake/packages/importGraph"
require proofwidgets from "../../.lake/packages/proofwidgets"
require aesop from "../../.lake/packages/aesop"
require Qq from "../../.lake/packages/Qq"
require batteries from "../../.lake/packages/batteries"
require Cli from "../../.lake/packages/Cli"

meta if run_io Option.isSome <$> IO.getEnv "LOOGLE_SECCOMP" then do
  target loogle_seccomp.o pkg : System.FilePath := do
    let oFile := pkg.buildDir / "loogle_seccomp.o"
    let srcJob ← inputTextFile <| pkg.dir / "loogle_seccomp.c"
    let flags := #["-I", (← getLeanIncludeDir).toString, "-fPIC"]
    buildO oFile srcJob flags #[] "cc"

  extern_lib libloogle_seccomp pkg := do
    let name := nameToStaticLib "loogle_seccomp"
    let ffiO ← fetch <| pkg.target ``loogle_seccomp.o
    buildStaticLib (pkg.staticLibDir / name) #[ffiO]

lean_lib Seccomp where
  roots := #[`Seccomp]
  precompileModules := true

lean_lib Loogle where
  roots := #[`Loogle]
  globs := #[.andSubmodules `Loogle]

lean_lib LoogleMathlibCache where
  roots := #[`LoogleMathlibCache]

lean_lib Tests where
  roots := #[`Tests]

@[default_target]
lean_exe loogle where
  root := `Loogle
  supportInterpreter := true
EOF

if [[ -f "$loogle_ws/lake-manifest.json" ]]; then
  mv "$loogle_ws/lake-manifest.json" "$loogle_ws/lake-manifest.upstream.json"
fi

(
  cd "$loogle_ws"
  targets=(loogle)
  if [[ "${LOOGLE_BUILD_MATHLIB_CACHE:-0}" == "1" ]]; then
    targets+=(LoogleMathlibCache)
  fi
  MATHLIB_NO_CACHE_ON_UPDATE=1 "${HOME}/.elan/bin/lake" build "${targets[@]}"
)

echo "Built local loogle workspace at $loogle_ws"
echo "Binary: $loogle_ws/.lake/build/bin/loogle"
