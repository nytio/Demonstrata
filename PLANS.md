# PLANS

Usar este archivo como log acumulado de planes:
- Append-only por `Plan ID` para planes cerrados (no sobreescribir historico).
- Agregar nuevas secciones al final, incluso para fases nuevas de un mismo objetivo.
- Se permite editar solo la seccion del plan activo para actualizar estado,
  checklist y evidencia.
- Si un plan deja de aplicar, marcarlo como `Cancelado` y explicar motivo.

## [PLAN-20260402-01] [Bootstrap Lean + Codex para demostraciones formales]

**Plan ID:** [PLAN-20260402-01] (debe coincidir con el encabezado de la seccion)
**Objetivo General:** Preparar este directorio como un workspace reproducible para
Lean 4 + mathlib + Codex CLI, con estructura local, scripts de verificacion y
skills repo-locales orientadas a demostraciones formales.
**Owner:** [Codex]
**Fecha de inicio:** [2026-04-02]
**Estado de aprobacion:** [Aprobado]
**Aprobado por:** [Usuario (chat)]
**Timestamp de aprobacion:** [2026-04-02T20:35:07.970+0000]
**Evidencia de aprobacion (chat/referencia):** [Conversacion actual: mensaje del usuario "Plan aprobado, continua con la implementación"]
**Evidencia de /plan:** [no interactivo/sin slash commands: `codex exec --skip-git-repo-check --json "Lee instrucciones.md y produce un plan breve en 3 fases para preparar este repositorio: instalaciones, estructura de directorios, scripts y skills locales para Lean/Codex. No ejecutes cambios; solo planifica."` ejecutado el 2026-04-02; `thread_id=019d4fe2-8540-7681-a4e7-9c904f934253`; evidencia visible en la sesion actual con eventos `todo_list` y mensaje final `# Plan`; referencia oficial: https://developers.openai.com/codex/noninteractive/#make-output-machine-readable]

**Aplicabilidad de esta skill (no pequena):**
- [x] Cumple al menos 2 criterios de no-pequena (pasos dependientes, impacto multi-modulo/componente critico, validacion no trivial).
- [x] No es tarea trivial de un solo paso.

**Alcance y Entregables:**
- Incluye: inicializacion del repositorio local; instalacion/configuracion de
  Lean mediante `elan`; validacion de `codex` 0.118.0 ya presente; bootstrap del
  proyecto Lean con dependencia de `mathlib`; estructura sugerida (`.codex/`,
  `.agents/skills/`, `scripts/`, arbol Lean); `AGENTS.md`; reglas locales de
  Codex; scripts de verificacion/parseo; skills `lean-verify` y `lean-prove`;
  dependencias Python necesarias para esos scripts.
- Excluye: desarrollo de teoremas concretos; CI remota; generacion inicial de
  docs HTML pesadas de mathlib; exportaciones NDJSON/indices semanticos salvo
  que aparezcan como dependencia imprescindible; cambios en configuracion global
  del usuario fuera de lo necesario para que `elan` funcione.

**Supuestos:**
- El directorio `/home/mario/code/mimate` es el destino definitivo del proyecto.
- Se permite inicializar Git localmente porque `codex exec` y el flujo propuesto
  funcionan mejor dentro de un repositorio.
- `codex-cli 0.118.0` ya instalado se considera valido si pasa las verificaciones.
- Los scripts Python de apoyo deben priorizar stdlib; si hace falta libreria
  externa, se declarara en `requirements.txt` y se instalara con `.venv/bin/pip`.

**Dependencias:**
- Sistema ya disponible: `python3`, `node`, `npm`, `git`, `curl`.
- Pendiente de instalar: `elan` (para `lean` y `lake`).
- Dependencia del proyecto: `mathlib4` via Lake.
- Referencias consultadas:
  - OpenAI Docs: `codex/noninteractive`, `codex/config-reference`,
    `codex/skills`.
  - Context7: `/leanprover/lean4`, `/leanprover-community/mathlib4`.

**Tipo de tarea:** [Mixta]
**Nivel de riesgo/complejidad:** [Medio]
**Modo de planificacion:** [Completo (2-3 alternativas)]
**Origen de alternativas:** [Analisis manual en PLANS.md]
**Justificacion del modo elegido:** Hay instalaciones externas, bootstrap de
proyecto, varios artefactos persistentes y validacion cruzada entre toolchains,
scripts y skills. Un plan simple seria insuficiente.
**Modo de seguimiento en `PROGRESS.md`:** [Estandar]
**Justificacion del modo de seguimiento:** El trabajo tiene varios hitos claros
(bootstrap repo, toolchain/proyecto Lean, automatizacion/skills) y conviene
sincronizar al cierre de cada uno sin llegar a bitacora estricta paso a paso.

**Definicion de Hecho (DoD) - marcar solo criterios aplicables al tipo de tarea:**
- [x] Tipo de tarea declarado y consistente con el alcance.
- [x] (`Codigo` o `Mixta`) Suites relevantes ejecutadas en verde: `.venv/bin/pytest -q` (si hay tests), `lake build --wfail`.
- [ ] (`Codigo` o `Mixta`) Si no hay tests aplicables, validacion manual reproducible documentada.
- [x] (`Configuracion/DevEx` u `Operacion/Infra`) Validacion reproducible ejecutada y documentada.
- [x] Revision de cambios cerrada sin hallazgos bloqueantes (`Critico`/`Alto`).
- [x] Hallazgos clasificados con rubrica de severidad cuando la herramienta no reporta severidad explicita.
- [x] Documentacion actualizada en: `AGENTS.md`, `PLANS.md`, `PROGRESS.md` (si aplica), `README.md` (si aplica).
- [x] Criterios de aceptacion funcional cumplidos:
  - [CA-1] `codex`, `lean`, `lake` y `python` quedan operativos desde este repo.
  - [CA-2] El proyecto Lean con `mathlib` compila en modo estricto sin `sorry`.
  - [CA-3] Existen scripts reproducibles para build completo, chequeo por archivo y resumen de errores JSON.
  - [CA-4] Existen skills repo-locales utilizables para verificar y redactar demostraciones.
- [ ] Rollback definido y validado (si aplica).

**Criterios minimos de salida (para estado `Completado`):**
- [x] No hay bloqueantes abiertos (funcionales, seguridad o tests).
- [x] Los checks DoD aplicables estan marcados como cumplidos.
- [x] Existe evidencia verificable de validacion (comandos, logs, diff o commit).

**Riesgos Identificados y Mitigaciones:**
- Riesgo: `lake new ... math` cree un subdirectorio y no un bootstrap limpio en
  la raiz actual.
  - Mitigacion: validar primero la mejor estrategia; si hace falta, generar en
    directorio temporal y mover el contenido minimo necesario.
- Riesgo: toolchain de Lean o `mathlib` no coincida con el comando descrito en
  `instrucciones.md`.
  - Mitigacion: usar `elan` y el `lean-toolchain` recomendado por `mathlib`;
    validar con `lake exe cache get` y `lake build`.
- Riesgo: scripts Python requieran dependencias externas innecesarias.
  - Mitigacion: preferir stdlib; solo instalar librerias justificadas.
- Riesgo: reglas de Codex demasiado restrictivas o demasiado permisivas.
  - Mitigacion: empezar con allowlist minima para verificaciones Lean y dejar
    comentarios/documentacion clara para ajuste posterior.

**Rubrica de severidad de hallazgos (fuente de verdad):**
- Canonica en: `SKILL.md` de la skill `orquestador-proyecto` (`Rubrica de severidad para hallazgos`).
- Si una herramienta no reporta severidad, clasificar cada hallazgo con esa rubrica
  y registrar la clasificacion/evidencia en este plan.
- Si existe duda entre dos severidades, usar la mas alta de forma preventiva.

**Alternativas Evaluadas y Rubrica:**
- Escala cuantitativa recomendada: `1..5` por criterio (`5` es mejor).
- Pesos:
  - Alcance (20%)
  - Simplicidad (20%)
  - Riesgo tecnico (25%)
  - Testabilidad (20%)
  - Mantenibilidad (15%)
- Alternativa A: bootstrap repo-local reproducible; instalar `elan`; crear
  proyecto Lean + `mathlib`; mantener reglas, scripts y skills dentro del repo.
  - Score por criterio: [A=5 S=4 R=4 T=5 M=5]
  - Puntaje total ponderado: [90/100]
- Alternativa B: configurar manualmente archivos Lean/Lake y dependencias sin
  usar bootstrap de `mathlib`.
  - Score por criterio: [A=4 S=2 R=2 T=3 M=3]
  - Puntaje total ponderado: [56/100]
- Alternativa C: mover reglas/skills a nivel usuario (`~/.codex`, `~/.agents`)
  y dejar el repo con minima estructura.
  - Score por criterio: [3 S=3 R=3 T=2 M=2]
  - Puntaje total ponderado: [51/100]

**Plan Seleccionado (resumen):**
Elegir la alternativa A. Maximiza portabilidad y reproducibilidad: cualquier
sesion de Codex dentro del repo vera las reglas, skills y scripts adecuados, y
el bootstrap con `mathlib` reduce el riesgo de una configuracion Lean incompleta.

## Pasos del Plan

- [x] STEP-01: Inicializar el repositorio y la estructura base de trabajo.
  - Evidencia/resultado esperado: existen `.git/`, `.codex/`, `.agents/skills/`,
    `scripts/` y el layout inicial esperado.
  - Validacion: `git status --short`, `fdfind -HI . -d 2`.
  - Artefacto esperado: estructura persistida en el repo.
  - Evidencia capturada: `git init`; creacion de `.codex/rules/`,
    `.agents/skills/`, `scripts/`, `tools/`, `docs/`; validado con
    `git status --short` y `fdfind -HI . /home/mario/code/mimate -d 2`.
- [x] STEP-02: Instalar y validar `elan`, `lean` y `lake`; bootstrap del proyecto
  Lean con dependencia de `mathlib`.
  - Evidencia/resultado esperado: `lean --version`, `lake --version`,
    `lean-toolchain`, `lakefile.*` y cache de `mathlib` disponibles.
  - Validacion: `~/.elan/bin/elan --version`, `~/.elan/bin/lake exe cache get`,
    `~/.elan/bin/lake build`.
  - Artefacto esperado: proyecto Lean funcional en este directorio.
  - Evidencia capturada: `elan 4.2.1`; `Lean 4.29.0`; `Lake 5.0.0-src+98dc76e`;
    scaffold `Mimate` generado con la plantilla `math`; cache de `mathlib`
    reconstruida en la raiz con `scripts/get_mathlib_cache.sh`.
- [x] STEP-03: Configurar Codex a nivel repo (`AGENTS.md`, `.codex/config.toml`,
  reglas) y scripts de automatizacion/verificacion.
  - Evidencia/resultado esperado: scripts ejecutables para build estricto,
    chequeo por archivo y resumen de JSON; reglas repo-locales presentes.
  - Validacion: ejecucion de cada script con ayuda o caso real; `lake build --wfail`;
    chequeo JSON por archivo.
  - Artefacto esperado: `AGENTS.md`, `.codex/`, `scripts/`, dependencias Python.
  - Evidencia capturada: creados `AGENTS.md`, `.codex/config.toml`,
    `.codex/rules/default.rules`, `requirements.txt`, `scripts/`, `tools/`,
    `tests/`; `codex execpolicy check` valido `allow` para `lake build --wfail`
    y `prompt` para `git commit`; `compileall` sin errores.
- [x] STEP-04: Crear las skills repo-locales `lean-verify` y `lean-prove` con
  `SKILL.md` y recursos auxiliares.
  - Evidencia/resultado esperado: skills detectables bajo `.agents/skills/` con
    instrucciones claras y, si aplica, scripts/referencias.
  - Validacion: inspeccion estructural del layout y consistencia con la doc de
    skills; validacion manual de activacion esperada.
  - Artefacto esperado: `.agents/skills/lean-verify/`, `.agents/skills/lean-prove/`.
  - Evidencia capturada: `fdfind -HI . /home/mario/code/mimate/.agents/skills -d 2`
    lista ambas skills y sus `SKILL.md`.
- [x] STEP-05: Ejecutar validaciones finales, revisar diff y cerrar trazabilidad.
  - Evidencia/resultado esperado: build final en verde, revision del diff y
    actualizacion del plan/progreso.
  - Validacion: `lake build --wfail`, `.venv/bin/pytest -q` (si aplica),
    `git diff -U3`.
  - Artefacto esperado: `PLANS.md`/`PROGRESS.md` sincronizados y estado final.
  - Evidencia capturada: `scripts/build_strict.sh` en verde; `scripts/check_lean_json.sh Mimate/Basic.lean`
    con exit 0; `.venv/bin/pytest -q` -> `2 passed`; `.venv/bin/python -m compileall -q scripts tools tests`
    en verde; revision manual apoyada en `git status --short` e inspeccion de
    archivos clave (el repo no tenia `HEAD`, asi que `git diff HEAD` aun no aplicaba).

**Validacion Manual (solo si no hay tests automatizados):**
- Escenario 1: ejecutar el script de build estricto desde raiz y confirmar salida exitosa.
- Escenario 2: ejecutar el chequeo por archivo sobre un `.lean` del proyecto y confirmar salida JSON procesable.
- Escenario 3: revisar que las skills repo-locales existen con `SKILL.md` y descripciones acotadas.
- Evidencia capturada en: salida de comandos y actualizacion de `PLANS.md`/`PROGRESS.md`.

**Plan de Rollback:**
- Trigger: toolchain rota, bootstrap Lean invalido o layout repo-local no usable.
- Acciones:
  - Eliminar artefactos del repo creados por este setup.
  - Revertir bootstrap Lean si se generaron archivos incompatibles.
  - Desinstalar toolchain de proyecto o `elan` solo si el usuario lo solicita.
- Verificacion posterior: confirmar que el directorio vuelve a quedar sin los
  artefactos agregados y que no quedan binarios/path parciales referenciados.

**Comandos Relevantes:**
- `git init` - crear repositorio local requerido por el flujo de Codex.
- `curl https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -sSf | sh -s -- -y` - instalar `elan`.
- `~/.elan/bin/lake +leanprover-community/mathlib4:lean-toolchain new <name> math` - bootstrap recomendado por `mathlib`.
- `~/.elan/bin/lake exe cache get` - descargar artefactos compilados de `mathlib`.
- `~/.elan/bin/lake build --wfail` - validar el proyecto en modo estricto.
- `.venv/bin/python -m pip install -r requirements.txt` - instalar dependencias Python del repo.
- Fallback si faltan herramientas/skills: checklist manual con `git diff -U3`,
  validaciones reproducibles y estructura minima documentada.

**Trazabilidad (links):**
- Issue/Ticket: [N/A]
- PR/Commit: [N/A]
- Decision(es) relacionada(s): [DEC-20260402-01]

**Sincronizacion con PROGRESS.md (si existe):**
- Modo de seguimiento activo: [Estandar]
- Ultimo sync confirmado: [2026-04-02T20:51:28.191+0000]
- Divergencias detectadas: [Ninguna]

**Estado Actual:** [Completado]
**Ultima Actualizacion:** [2026-04-02T20:51:28.191+0000]

---
