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
    scaffold `Biblioteca` generado con la plantilla `math`; cache de `mathlib`
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
  - Evidencia capturada: `scripts/build_strict.sh` en verde; `scripts/check_lean_json.sh Biblioteca/Basic.lean`
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

## [PLAN-20260403-01] [Publicacion GitHub con licencia MIT y README orientado a usuario]

**Plan ID:** [PLAN-20260403-01] (debe coincidir con el encabezado de la seccion)
**Objetivo General:** Preparar el repositorio para una publicacion clara en
GitHub mediante una licencia MIT en raiz, un `README.md` profesional orientado
a usuarios y un `.gitignore` que preserve fuentes y artefactos publicables.
**Owner:** [Codex]
**Fecha de inicio:** [2026-04-03]
**Estado de aprobacion:** [Aprobado]
**Aprobado por:** [Usuario (chat)]
**Timestamp de aprobacion:** [2026-04-03T17:12:09.254+0000]
**Evidencia de aprobacion (chat/referencia):** [Conversacion actual: mensaje del usuario "Apruebo el plan"]
**Evidencia de /plan:** [no interactivo/sin slash commands: `codex exec --skip-git-repo-check --json 'Analiza el repositorio actual y produce un plan breve en 3 fases para dejarlo listo para publicarse en GitHub: licencia MIT, README profesional y ajuste de .gitignore para conservar .tex/.lean/.pdf y excluir artefactos temporales de build. No ejecutes cambios; solo planifica.'` ejecutado el 2026-04-03; `thread_id=019d544f-904e-7ca0-9bd6-908944c51514`; evidencia visible en la sesion actual con items `item_39` y `item_40`; referencia oficial: https://developers.openai.com/codex/noninteractive/#make-output-machine-readable]

**Aplicabilidad de esta skill (no pequena):**
- [x] Cumple al menos 2 criterios de no-pequena (pasos dependientes, impacto multi-modulo/componente critico, validacion no trivial).
- [x] No es tarea trivial de un solo paso.

**Alcance y Entregables:**
- Incluye: crear `LICENSE` con texto MIT; rediseñar `README.md` para presentar
  el proyecto, sus ventajas, ejemplos de uso, la dinamica del skill
  `olympiad-formalize`, los archivos que genera, dependencias de sistema,
  librerias Python y ecosistema Lean/Mathlib; ajustar `.gitignore` para
  versionar `.lean`, `.tex` y `.pdf` publicables mientras se ignoran artefactos
  temporales.
- Excluye: cambiar la estructura del repo; renombrar el proyecto o namespace
  Lean; modificar demostraciones `.lean`; alterar workflows de GitHub Actions;
  decidir o crear un remoto GitHub concreto.

**Supuestos:**
- El nombre editorial puede presentarse como `Biblioteca` aunque el directorio
  local del repo siga siendo `mimate`.
- La licencia solicitada debe ser MIT y el titular puede dejarse alineado con el
  autor ya visible en los `.tex` del blueprint salvo que el usuario indique otro.
- Los PDFs archivados en `blueprint/library/pdf/` forman parte del material
  publicable, mientras `blueprint/build/` sigue siendo temporal.

**Dependencias:**
- Sistema y herramientas a documentar: `git`, `python3`, entorno `.venv`,
  `elan`, `lean`, `lake`, `latexmk`, `xelatex`.
- Dependencias Python declaradas: `pytest`, `sympy`.
- Dependencias Lean visibles por el proyecto: `mathlib` (`v4.29.0`) y el
  toolchain `leanprover/lean4:v4.29.0`.
- Referencias consultadas: `README.md`, `.gitignore`, `requirements.txt`,
  `lakefile.toml`, `lean-toolchain`, `.agents/skills/olympiad-formalize/SKILL.md`,
  `tools/demo_library.py`, `tools/blueprint_paper.py`, `clean.sh`.

**Tipo de tarea:** [Mixta]
**Nivel de riesgo/complejidad:** [Medio]
**Modo de planificacion:** [Completo (2-3 alternativas)]
**Origen de alternativas:** [Analisis manual en PLANS.md + evidencia externa en `codex exec --json`]
**Justificacion del modo elegido:** El cambio afecta la presentacion publica del
repositorio, la politica de archivos versionados y la documentacion principal.
Hay que equilibrar exactitud tecnica, copy editorial y semantica de artefactos
publicables frente a temporales.
**Modo de seguimiento en `PROGRESS.md`:** [Estandar]
**Justificacion del modo de seguimiento:** El trabajo se puede dividir por hitos
claros (licencia, README, ignores y validacion final) y ya existe
`PROGRESS.md`; conviene sincronizar el avance por step una vez aprobado el plan.

**Definicion de Hecho (DoD) - marcar solo criterios aplicables al tipo de tarea:**
- [x] Tipo de tarea declarado y consistente con el alcance.
- [x] (`Codigo` o `Mixta`) Suites relevantes ejecutadas en verde: `.venv/bin/pytest -q`.
- [ ] (`Codigo` o `Mixta`) Si no hay tests aplicables, validacion manual reproducible documentada.
- [x] (`Documentacion`) Exactitud tecnica verificada y enlaces/comandos validados.
- [x] (`Configuracion/DevEx` u `Operacion/Infra`) Validacion reproducible ejecutada y documentada.
- [x] Revision de cambios cerrada sin hallazgos bloqueantes (`Critico`/`Alto`).
- [x] Hallazgos clasificados con rubrica de severidad cuando la herramienta no reporta severidad explicita.
- [x] Documentacion actualizada en: `README.md`, `PLANS.md`, `PROGRESS.md` (si aplica), `LICENSE`.
- [x] Criterios de aceptacion funcional cumplidos:
  - [CA-1] GitHub puede detectar una licencia MIT en la raiz.
  - [CA-2] `README.md` explica el proyecto, Lean 4, dependencias, ventajas,
    ejemplos de uso y el workflow `olympiad-formalize` con artefactos reales.
  - [CA-3] `.gitignore` conserva `.lean`, `.tex` y `.pdf` publicables y sigue
    ignorando artefactos temporales de build.
- [ ] Rollback definido y validado (si aplica).

**Criterios minimos de salida (para estado `Completado`):**
- [x] No hay bloqueantes abiertos (funcionales, seguridad o tests).
- [x] Los checks DoD aplicables estan marcados como cumplidos.
- [x] Existe evidencia verificable de validacion (comandos, logs, diff o commit).

**Riesgos Identificados y Mitigaciones:**
- Riesgo: documentar un flujo de `olympiad-formalize` distinto al implementado.
  - Mitigacion: basar la seccion en `.agents/skills/olympiad-formalize/SKILL.md`
    y en los scripts reales que scaffoldean y compilan artefactos.
- Riesgo: abrir demasiado `.gitignore` y empezar a versionar basura temporal.
  - Mitigacion: conservar ignores de `.lake`, caches Python y
    `blueprint/build/`; validar con `git status --ignored`.
- Riesgo: fijar un branding publico que el usuario no quiera.
  - Mitigacion: mantener el enfoque editorial en `Biblioteca` sin renombrar
    archivos ni namespace; si aparece conflicto, elevarlo como decision aparte.

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
- Alternativa A: README integral orientado a GitHub, licencia MIT en raiz y
  `.gitignore` selectivo para preservar PDFs archivados.
  - Score por criterio: [A=5 S=4 R=4 T=5 M=5]
  - Puntaje total ponderado: [90/100]
- Alternativa B: cambios minimos; anadir licencia y un README corto, mantener el
  `README` actual casi intacto y seguir ignorando `blueprint/library/`.
  - Score por criterio: [A=2 S=5 R=3 T=2 M=2]
  - Puntaje total ponderado: [56/100]
- Alternativa C: publicar solo fuentes (`.lean` y `.tex`) y excluir todos los
  PDFs para forzar generacion local por parte del usuario final.
  - Score por criterio: [A=3 S=4 R=4 T=3 M=3]
  - Puntaje total ponderado: [68/100]

**Plan Seleccionado (resumen):**
Elegir la alternativa A. Es la unica que alinea el repo con una publicacion
convincente en GitHub sin perder el valor diferencial del proyecto: pruebas
formales en Lean, skill-based workflow para problemas olympiad y entregables
finales en PDF listos para consulta.

## Pasos del Plan

- [x] STEP-01: Añadir licencia MIT y reflejar la politica de distribucion.
  - Evidencia/resultado esperado: existe `LICENSE` en raiz con texto MIT y el
    README la menciona de forma consistente.
  - Validacion: `sed -n '1,40p' LICENSE`
  - Artefacto esperado: `LICENSE`.
  - Evidencia capturada: `LICENSE` creado con texto MIT; `README.md` enlaza a
    `LICENSE`.
- [x] STEP-02: Reescribir `README.md` con orientacion publica y tecnica.
  - Evidencia/resultado esperado: el README presenta el proyecto, ventajas,
    instalacion, stack Lean/Python, ejemplos, flujo `olympiad-formalize`,
    artefactos generados y valor de Lean 4.
  - Validacion: `sed -n '1,260p' README.md`
  - Artefacto esperado: `README.md`.
  - Evidencia capturada: nuevo README en espanol con secciones de valor,
    instalacion, ecosistema Lean/Python, flujo olimpico y artefactos generados.
- [x] STEP-03: Ajustar `.gitignore` para versionar fuentes y PDFs archivados sin
  versionar temporales.
  - Evidencia/resultado esperado: `blueprint/build/` sigue ignorado; los PDFs de
    `blueprint/library/pdf/` dejan de estar bloqueados; `.lean` y `.tex` no se
    ignoran por patron.
  - Validacion: `git status --short --ignored blueprint/build blueprint/library .gitignore`
  - Artefacto esperado: `.gitignore`.
  - Evidencia capturada: `git status --short --ignored blueprint/build blueprint/library .gitignore README.md LICENSE`
    muestra `?? blueprint/library/` y `!! blueprint/build/`.
- [x] STEP-04: Ejecutar validaciones y cerrar trazabilidad.
  - Evidencia/resultado esperado: diff revisado, tests/documentacion validados y
    `PLANS.md`/`PROGRESS.md` sincronizados.
  - Validacion: `.venv/bin/pytest -q`, `git diff -U3`, validacion manual del
    README y `git status --ignored`.
  - Artefacto esperado: trazabilidad actualizada.
  - Evidencia capturada: `.venv/bin/pytest -q` -> `22 passed`; `git diff -U3 HEAD`
    revisado sin hallazgos bloqueantes; validacion manual del README y de la
    politica de ignores completada.

**Validacion Manual (solo si no hay tests automatizados):**
- Escenario 1: comprobar que `README.md` menciona herramientas reales del repo y
  que los comandos citados existen.
- Escenario 2: verificar que `git status --ignored` muestra `blueprint/build/`
  como ignorado pero ya no `blueprint/library/pdf/`.
- Escenario 3: revisar que la seccion `olympiad-formalize` coincide con la
  skill y con los scripts `new_demo`/`build_blueprint_pdf`.
- Evidencia capturada en: diff final, salida de comandos y actualizacion de
  `PLANS.md`/`PROGRESS.md`.

**Plan de Rollback:**
- Trigger: el README pierde exactitud tecnica o `.gitignore` empieza a exponer
  artefactos temporales no deseados.
- Acciones:
  - Revertir `README.md`, `.gitignore` y `LICENSE` a su estado previo.
  - Restaurar la politica previa de ignores si los archivos publicables generan
    ruido inesperado.
- Verificacion posterior: confirmar con `git status --ignored` y lectura del
  README que el repo vuelve al estado anterior sin artefactos adicionales.

**Comandos Relevantes:**
- `.venv/bin/pytest -q` - asegurar que la automatizacion Python del repo sigue estable.
- `git status --short --ignored blueprint/build blueprint/library .gitignore` -
  validar la politica de ignores antes y despues del cambio.
- `git diff -U3` - revisar los cambios documentales y de policy.
- `sed -n '1,260p' README.md` - inspeccion final del README renderizable.
- Fallback si faltan herramientas/skills: checklist manual de exactitud
  documental y politica de ignores.

**Trazabilidad (links):**
- Issue/Ticket: [N/A]
- PR/Commit: [N/A]
- Decision(es) relacionada(s): [N/A]

**Sincronizacion con PROGRESS.md (si existe):**
- Modo de seguimiento activo: [Estandar]
- Ultimo sync confirmado: [2026-04-03T17:17:10.738+0000]
- Divergencias detectadas: [Ninguna]

**Estado Actual:** [Completado]
**Ultima Actualizacion:** [2026-04-03T17:17:10.738+0000]

---
