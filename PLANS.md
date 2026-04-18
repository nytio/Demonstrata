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

## [PLAN-20260403-02] [Migrar el anexo Lean del blueprint a minted con color y Unicode]

**Plan ID:** [PLAN-20260403-02] (debe coincidir con el encabezado de la seccion)
**Objetivo General:** Mejorar la presentacion tipografica del codigo Lean 4 en
los PDF del blueprint usando `minted`, preservando la calidad editorial del
documento impreso y la compatibilidad Unicode del anexo.
**Owner:** [Codex]
**Fecha de inicio:** [2026-04-03]
**Estado de aprobacion:** [Aprobado]
**Aprobado por:** [Usuario (chat)]
**Timestamp de aprobacion:** [2026-04-03T23:00:44.330+0000]
**Evidencia de aprobacion (chat/referencia):** [Conversacion actual: mensaje del usuario "Apruebo plan"]
**Evidencia de /plan:** [no interactivo/sin slash commands: planificacion registrada en esta sesion mediante `update_plan` el 2026-04-03; adicionalmente se intento `codex exec --skip-git-repo-check --json "Analiza el repositorio actual y produce un plan breve en 3 fases para mejorar la presentación del código Lean 4 en los PDFs del blueprint usando minted..."` a las 2026-04-03T22:55Z, pero fallo por restriccion de red del sandbox al contactar `chatgpt.com` y `developers.openai.com`; se solicito rerun escalado para dejar evidencia formal equivalente a la recomendada por la skill]

**Aplicabilidad de esta skill (no pequena):**
- [x] Cumple al menos 2 criterios de no-pequena (pasos dependientes, impacto multi-modulo/componente critico, validacion no trivial).
- [x] No es tarea trivial de un solo paso.

**Alcance y Entregables:**
- Incluye: integrar `minted` en la generacion del PDF del blueprint para el
  codigo Lean del anexo; mantener `XeLaTeX`; habilitar `-shell-escape`; hacer
  que la compilacion use `pygmentize` con soporte real de `lean4`; definir una
  presentacion en color orientada a impresion; agregar o ajustar pruebas
  unitarias de `tools/blueprint_paper.py`; validar build real del PDF.
- Excluye: remaquetar el cuerpo narrativo de las secciones `.tex`; cambiar el
  namespace Lean o la estructura del repo; instalar paquetes globales salvo que
  una carencia comprobada lo exija; migrar todo el blueprint a otra clase
  documental o a otro motor TeX sin evidencia fuerte.

**Supuestos:**
- La regla del repo de conservar un layout compatible con AMS via `amsart`
  sigue vigente y pesa mas que recomendaciones genericas basadas en `article`.
- El producto impreso mejora mas con resaltado sintactico + mejor caja de
  codigo que con un cambio global de `\documentclass`.
- El entorno virtual del repo es la fuente de Python controlada por el proyecto.
- `minted` ya esta instalado en TeX Live local, por lo que no se requiere una
  instalacion adicional inicial para empezar.

**Dependencias:**
- Toolchain local detectada:
  - `XeTeX 0.999995 (TeX Live 2023/Debian)`
  - `latexmk 4.83`
  - `minted.sty` local: `2023/12/18 v2.9`
  - `pygmentize` del sistema: `2.17.2` (sin lexer `lean4`)
  - `.venv/bin/pygmentize`: `2.20.0` (con lexer `lean4`)
- Archivos/modulos previsiblemente afectados:
  - `tools/blueprint_paper.py`
  - `blueprint/src/macros/common.tex`
  - `tests/test_blueprint_paper.py`
  - `requirements.txt` solo si apareciera una dependencia faltante reproducible
- Referencias consultadas:
  - CTAN `minted` (version actual publicada 3.8.0 al 2026-03-03)
  - Pygments docs: `Lean4Lexer` agregado en `2.18.0`
  - CTAN `tcolorbox` como alternativa/acompanamiento para cajas coloreadas

**Tipo de tarea:** [Mixta]
**Nivel de riesgo/complejidad:** [Medio]
**Modo de planificacion:** [Completo (2-3 alternativas)]
**Origen de alternativas:** [Analisis manual en PLANS.md]
**Justificacion del modo elegido:** Hay cambios coordinados entre Python,
LaTeX, build tooling y pruebas. Ademas existe un trade-off editorial no trivial
entre mantener `amsart`, usar color en impresion y controlar el lexer Lean 4.
**Modo de seguimiento en `PROGRESS.md`:** [Estandar]
**Justificacion del modo de seguimiento:** El trabajo tiene hitos claros
(pipeline, macros/estilo, validacion), pero no requiere una bitacora estricta
paso a paso.

**Definicion de Hecho (DoD) - marcar solo criterios aplicables al tipo de tarea:**
- [x] Tipo de tarea declarado y consistente con el alcance.
- [x] (`Codigo` o `Mixta`) Suites relevantes ejecutadas en verde: `.venv/bin/pytest -q`, `scripts/build_blueprint_pdf.sh`.
- [ ] (`Codigo` o `Mixta`) Si no hay tests aplicables, validacion manual reproducible documentada.
- [x] (`Configuracion/DevEx` u `Operacion/Infra`) Validacion reproducible ejecutada y documentada.
- [x] Revision de cambios cerrada sin hallazgos bloqueantes (`Critico`/`Alto`).
- [x] Hallazgos clasificados con rubrica de severidad cuando la herramienta no reporta severidad explicita.
- [x] Documentacion actualizada en: `PLANS.md`, `PROGRESS.md` (si aplica) y archivos tecnicos solo si el cambio lo amerita.
- [x] Criterios de aceptacion funcional cumplidos:
  - [CA-1] El PDF del blueprint sigue compilando con `XeLaTeX`.
  - [CA-2] El anexo muestra codigo Lean con `minted`, color y soporte Unicode.
  - [CA-3] La compilacion usa un lexer `lean4` real cuando esta disponible en el entorno del repo.
  - [CA-4] El documento sigue siendo apto para impresion y mantiene el look AMS del proyecto.
- [ ] Rollback definido y validado (si aplica).

**Criterios minimos de salida (para estado `Completado`):**
- [x] No hay bloqueantes abiertos (funcionales, seguridad o tests).
- [x] Los checks DoD aplicables estan marcados como cumplidos.
- [x] Existe evidencia verificable de validacion (comandos, logs, diff o commit).

**Riesgos Identificados y Mitigaciones:**
- Riesgo: `minted` use el `pygmentize` del sistema y falle con `lean4`.
  - Mitigacion: encaminar explicitamente el build para que prefiera
    `.venv/bin/pygmentize` y agregar deteccion/fallback controlado del lexer.
- Riesgo: `-shell-escape` introduzca un cambio sensible en el pipeline de build.
  - Mitigacion: limitarlo al builder del blueprint, documentarlo y evitar
    habilitarlo en flujos innecesarios.
- Riesgo: cambiar `amsart` por `article` degrade el producto editorial.
  - Mitigacion: tratar `article` solo como alternativa comparada, no como
    default, salvo que una prueba real muestre una mejora objetiva.
- Riesgo: estilos muy saturados se impriman mal o resten legibilidad.
  - Mitigacion: escoger un tema claro y sobrio (`friendly`, `xcode` o similar)
    y mantener contraste alto.

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
- Alternativa A: mantener `amsart` y `XeLaTeX`; migrar solo el anexo Lean a
  `minted`; hacer que el builder prefiera `.venv/bin/pygmentize`; usar un tema
  claro en color y, si aporta, una caja ligera para mejorar la lectura impresa.
  - Score por criterio: [A=5 S=4 R=4 T=5 M=5]
  - Puntaje total ponderado: [91/100]
- Alternativa B: cambiar el documento a `article` siguiendo la receta generica
  `fontspec + FreeMono + minted`, sin preservar el formato AMS actual.
  - Score por criterio: [A=3 S=4 R=2 T=4 M=3]
  - Puntaje total ponderado: [61/100]
- Alternativa C: no usar `minted`; mantener el render actual y mejorar solo con
  macros LaTeX (`xcolor`, `tcolorbox`, `listings` u otro wrapper local).
  - Score por criterio: [A=2 S=3 R=4 T=3 M=3]
  - Puntaje total ponderado: [59/100]

**Plan Seleccionado (resumen):**
Elegir la alternativa A. Es la unica que cumple simultaneamente con el pedido
de usar `minted`, el objetivo de mejor presentacion impresa y la restriccion del
repo de permanecer en un formato AMS. La evidencia local muestra que
`amsart + fontspec + minted` funciona; el problema real no es la clase del
documento, sino la seleccion de `pygmentize`. El color es viable nativamente en
`minted`; `tcolorbox` queda como refinamiento editorial opcional, no como
sustituto del resaltado.

## Pasos del Plan

- [x] STEP-01: Ajustar el pipeline del builder para compilar con `minted` de
  forma reproducible.
  - Evidencia/resultado esperado: `latexmk` se ejecuta con `-shell-escape` y
    el proceso ve `.venv/bin/pygmentize` antes que el binario del sistema.
  - Validacion: deteccion del lexer disponible y luego `scripts/build_blueprint_pdf.sh`.
  - Artefacto esperado: cambios en `tools/blueprint_paper.py`.
  - Evidencia capturada: `tools/blueprint_paper.py` ahora resuelve `MintedConfig`,
    antepone `.venv/bin` al `PATH` de `latexmk`, habilita `-shell-escape` y
    detecta el lexer `lean4` desde `pygmentize`.
- [x] STEP-02: Sustituir el render lineal del anexo por inclusiones `minted`
  con estilo de impresion.
  - Evidencia/resultado esperado: `lean_appendix.tex` deja de emitir
    `\leanline{...}` y pasa a usar `\inputminted` o macro equivalente con
    `breaklines`, fuente monoespaciada Unicode, estilo en color y ajustes de
    legibilidad.
  - Validacion: `.venv/bin/pytest -q tests/test_blueprint_paper.py -k appendix`
    y build real del PDF.
  - Artefacto esperado: cambios en `blueprint/src/macros/common.tex`,
    `tools/blueprint_paper.py`, `tests/test_blueprint_paper.py`.
  - Evidencia capturada: `blueprint/src/macros/common.tex` incorpora `minted`,
    `FreeMono` como mono global y el macro `\leaninputfile`; el anexo generado
    usa `\inputminted{lean4}{...}` con ruta relativa y estilo `friendly`.
- [x] STEP-03: Validar el resultado editorial, revisar diff y cerrar trazabilidad.
  - Evidencia/resultado esperado: build del PDF en verde, diffs revisados y
    configuracion final documentada en `PLANS.md`/`PROGRESS.md`.
  - Validacion: `.venv/bin/pytest -q`, `scripts/build_blueprint_pdf.sh`,
    `git diff -U3`.
  - Artefacto esperado: PDF actualizado en `blueprint/library/pdf/` y plan con
    estado sincronizado.
  - Evidencia capturada: `.venv/bin/pytest -q` -> `24 passed`;
    `timeout 20s scripts/check_blueprint_decls.sh` -> `Checked 2 Lean declaration reference(s) from blueprint/src.`;
    `scripts/build_blueprint_pdf.sh` produjo el PDF archivado en
    `blueprint/library/pdf/IMO_20260403_085959_finite_sets_with_divisibility_b_plus_two_c.pdf`;
    revision manual de `git diff -U3` sin hallazgos bloqueantes.

**Validacion Manual (solo si no hay tests automatizados):**
- Escenario 1: compilar el demo actual del blueprint y confirmar que el anexo
  usa sintaxis coloreada con caracteres Unicode de Lean 4.
- Escenario 2: inspeccionar visualmente que el estilo elegido siga siendo
  legible en impresion y no rompa lineas de forma agresiva.
- Evidencia capturada en: salida de `scripts/build_blueprint_pdf.sh` y PDF
  archivado bajo `blueprint/library/pdf/`.

**Plan de Rollback:**
- Trigger: el build con `minted` deja de ser reproducible, el PDF pierde
  legibilidad, o `-shell-escape` introduce una regresion operativa inaceptable.
- Acciones:
  - Revertir el builder a la ruta actual sin `minted`.
  - Restaurar el render del anexo basado en `\leanline`.
  - Eliminar configuracion auxiliar de `minted` o estilos si quedaron inutiles.
- Verificacion posterior: `scripts/build_blueprint_pdf.sh` vuelve a producir el
  PDF previo sin errores.

**Comandos Relevantes:**
- `.venv/bin/pygmentize -V` - verificar version y soporte de `lean4`.
- `pygmentize -V` - confirmar la version del sistema que no debe ganar el PATH.
- `scripts/build_blueprint_pdf.sh` - validacion real del flujo de PDF.
- `.venv/bin/pytest -q` - regresion de la automatizacion Python.
- `git diff -U3` - revision manual del cambio.
- Fallback si faltan herramientas/skills: inspeccion manual de `lean_appendix.tex`
  y build local con `latexmk` en el directorio de salida.

**Trazabilidad (links):**
- Issue/Ticket: [N/A]
- PR/Commit: [N/A]
- Decision(es) relacionada(s): [N/A por ahora; crear decision solo si se cambia la clase documental o se formaliza `tcolorbox` como patron editorial]

**Sincronizacion con PROGRESS.md (si existe):**
- Modo de seguimiento activo: [Estandar]
- Ultimo sync confirmado: [2026-04-03T23:11:29.546+0000]
- Divergencias detectadas: [Ninguna]

**Estado Actual:** [Completado]
**Ultima Actualizacion:** [2026-04-03T23:11:29.546+0000]

---

## [PLAN-20260403-03] [Persistir enunciado origen en PDFs de olympiad-formalize]

**Plan ID:** [PLAN-20260403-03] (debe coincidir con el encabezado de la seccion)
**Objetivo General:** Hacer que el flujo `olympiad-formalize PROBLEMA` preserve
el enunciado original en LaTeX y lo incluya de forma consistente en el PDF final
de la demostracion.
**Owner:** [Codex]
**Fecha de inicio:** [2026-04-03]
**Estado de aprobacion:** [Aprobado]
**Aprobado por:** [Usuario (chat)]
**Timestamp de aprobacion:** [2026-04-04T05:46:41.859+0000]
**Evidencia de aprobacion (chat/referencia):** [Conversacion actual: mensaje del usuario "Apruebo el plan"]
**Evidencia de /plan:** [no interactivo/sin slash commands: planificacion trazable en la sesion actual de Codex el 2026-04-03/2026-04-04 mediante exploracion previa del flujo `olympiad-formalize`, revision de `tools/demo_library.py`, `tools/blueprint_paper.py`, `blueprint/src/macros/common.tex`, tests asociados y actualizacion explicita de `functions.update_plan`; slash commands no disponibles en esta interfaz]

**Aplicabilidad de esta skill (no pequena):**
- [x] Cumple al menos 2 criterios de no-pequena (pasos dependientes, impacto multi-modulo/componente critico, validacion no trivial).
- [x] No es tarea trivial de un solo paso.

**Alcance y Entregables:**
- Incluye: definicion de una representacion persistente del enunciado original;
  actualizacion del scaffold TeX para nuevas demostraciones; ajuste de la skill
  `olympiad-formalize` para copiar el problema fuente; compatibilidad con el PDF
  final; pruebas y validacion del flujo.
- Excluye: backfill automatico de PDFs ya archivados; migracion masiva de demos
  anteriores; cambios en el contenido matematico de pruebas ya formalizadas.

**Supuestos:**
- El enunciado de entrada llega en LaTeX libre y puede ocupar varias lineas.
- El flujo normal de `olympiad-formalize` crea o edita una seccion bajo
  `blueprint/src/sections/`.
- El build por defecto sigue siendo de una sola demostracion actual, aunque el
  diseno no debe romper colecciones de varias secciones.

**Dependencias:**
- `tools/demo_library.py` para el scaffold de nuevas demos.
- `.agents/skills/olympiad-formalize/SKILL.md` y posiblemente
  `.agents/skills/lean-prove/SKILL.md` para la instruccion operativa.
- `blueprint/src/macros/common.tex` para el estilo del bloque en el PDF.
- `tests/test_demo_library.py` y validaciones del blueprint para cobertura.

**Tipo de tarea:** [Mixta]
**Nivel de riesgo/complejidad:** [Medio]
**Modo de planificacion:** [Completo (2-3 alternativas)]
**Origen de alternativas:** [Analisis manual en PLANS.md]
**Justificacion del modo elegido:** El cambio afecta skill, scaffold, macros TeX
y validacion del pipeline de PDF. Hay varias estrategias viables con trade-offs
reales entre robustez, simplicidad y preservacion de LaTeX multilinea.
**Modo de seguimiento en `PROGRESS.md`:** [Estandar]
**Justificacion del modo de seguimiento:** Conviene sincronizar al aprobar el
plan y al cierre de cada hito tecnico sin registrar cada lectura exploratoria.

**Definicion de Hecho (DoD) - marcar solo criterios aplicables al tipo de tarea:**
- [x] Tipo de tarea declarado y consistente con el alcance.
- [x] (`Codigo` o `Mixta`) Suites relevantes ejecutadas en verde: [`.venv/bin/pytest -q tests/test_demo_library.py tests/test_blueprint_paper.py`, `scripts/build_blueprint_pdf.sh` en replica segura bajo `/tmp/mimate_plan03_validation_min`].
- [ ] (`Codigo` o `Mixta`) Si no hay tests aplicables, validacion manual reproducible documentada.
- [x] (`Configuracion/DevEx` u `Operacion/Infra`) Validacion reproducible ejecutada y documentada.
- [x] Revision de cambios cerrada sin hallazgos bloqueantes (`Critico`/`Alto`).
- [x] Hallazgos clasificados con rubrica de severidad cuando la herramienta no reporta severidad explicita.
- [x] Documentacion actualizada en: [`.agents/skills/olympiad-formalize/SKILL.md`, `.agents/skills/lean-prove/SKILL.md`, `PLANS.md`, `PROGRESS.md`].
- [x] Criterios de aceptacion funcional cumplidos:
  - [x] [CA-1] Las nuevas demos scaffoldeadas contienen un lugar explicito y persistente para el enunciado original.
  - [x] [CA-2] `olympiad-formalize` queda instruida para copiar el problema fuente en ese bloque.
  - [x] [CA-3] El PDF final muestra el problema sin requerir postprocesado manual.
  - [x] [CA-4] El cambio soporta problemas en LaTeX multilinea sin parser fragil.
- [x] Rollback definido y validado (si aplica).

**Criterios minimos de salida (para estado `Completado`):**
- [x] No hay bloqueantes abiertos (funcionales, seguridad o tests).
- [x] Los checks DoD aplicables estan marcados como cumplidos.
- [x] Existe evidencia verificable de validacion (comandos, logs, diff o commit).

**Riesgos Identificados y Mitigaciones:**
- Riesgo: modelar el problema como metadata de una sola linea rompa casos con
  LaTeX multilinea o entornos matematicos.
  - Mitigacion: preferir una representacion como bloque TeX estructurado dentro
    de la propia seccion.
- Riesgo: el cambio quede solo en plantilla pero no en la skill operativa.
  - Mitigacion: actualizar la instruccion de `olympiad-formalize` para exigir
    copiar el enunciado inicial al bloque persistente.
- Riesgo: el estilo del nuevo bloque degrade la maquetacion del paper.
  - Mitigacion: usar una macro o entorno minimo en `common.tex` y validar con
    un build real del blueprint.

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
- Alternativa A: agregar un entorno/bloque `problemstatement` directamente en la
  seccion TeX y hacer que `olympiad-formalize` copie ahi el problema original.
  - Score por criterio: [A=5 S=5 R=5 T=4 M=5]
  - Puntaje total ponderado: [95/100]
- Alternativa B: extender la metadata comentada (`% problem:`) y el builder para
  parsearla e inyectarla en el front matter del paper.
  - Score por criterio: [A=4 S=2 R=2 T=4 M=3]
  - Puntaje total ponderado: [57/100]
- Alternativa C: guardar el problema en un archivo sidecar `.tex` separado e
  incluirlo desde el builder del PDF.
  - Score por criterio: [A=4 S=3 R=4 T=4 M=3]
  - Puntaje total ponderado: [73/100]

**Plan Seleccionado (resumen):**
Elegir la alternativa A. Es la unica opcion que soporta LaTeX multilinea sin
inventar un parser nuevo, mantiene el problema junto a la demostracion que lo
origina y hace que el PDF lo muestre de forma natural al principio de la
seccion, es decir, inmediatamente despues del abstract en el build normal de
una sola demo.

## Pasos del Plan

- [x] STEP-01: Introducir un bloque TeX reutilizable para el enunciado original
  y reflejarlo en el scaffold de nuevas demostraciones.
  - Evidencia/resultado esperado: el template generado por `scripts/new_demo.sh`
    incluye un placeholder explicito para el problema original.
  - Validacion: `.venv/bin/pytest -q tests/test_demo_library.py`
  - Artefacto esperado: `blueprint/src/macros/common.tex`, `tools/demo_library.py`,
    `tests/test_demo_library.py`
  - Evidencia capturada: se agrego el entorno `problemstatement` en
    `blueprint/src/macros/common.tex`; `tools/demo_library.py` ahora emite un
    bloque activo para prefijos de fuente como `IMO` y un placeholder comentado
    para `Demo`; `.venv/bin/pytest -q tests/test_demo_library.py tests/test_blueprint_paper.py`
    -> `20 passed`.
- [x] STEP-02: Actualizar las skills para que `olympiad-formalize` preserve el
  enunciado de entrada y lo coloque en el bloque persistente.
  - Evidencia/resultado esperado: la documentacion operativa indica copiar el
    problema fuente al bloque `problemstatement` cuando se crea o edita la demo.
  - Validacion: revision directa del diff y consistencia con el flujo descrito.
  - Artefacto esperado: `.agents/skills/olympiad-formalize/SKILL.md` y
    `.agents/skills/lean-prove/SKILL.md` si la integracion lo requiere.
  - Evidencia capturada: `olympiad-formalize` exige preservar el LaTeX original
    en el bloque `problemstatement`; `lean-prove` indica copiar ese enunciado al
    scaffold cuando el usuario lo haya proporcionado.
- [x] STEP-03: Ejecutar regresion del blueprint y revisar hallazgos.
  - Evidencia/resultado esperado: pruebas Python relevantes en verde y build del
    PDF sin regresiones.
  - Validacion: `.venv/bin/pytest -q tests/test_demo_library.py tests/test_blueprint_paper.py`,
    `scripts/build_blueprint_pdf.sh`, `git diff -U3`
  - Artefacto esperado: validacion reproducible documentada en `PLANS.md` y, tras
    aprobacion, sincronizacion con `PROGRESS.md`.
  - Evidencia capturada: revision manual de `git diff -U3` sin hallazgos
    bloqueantes; validacion segura en `/tmp/mimate_plan03_validation_min`
    creando `IMO_20260403_235539_problem_statement_validation`; el scaffold
    generado incluye `\\begin{problemstatement}` y el build
    `scripts/build_blueprint_pdf.sh --demo IMO_20260403_235539_problem_statement_validation`
    completo con exit 0; `pdftotext` sobre el PDF archivado confirma la salida
    `Problem: Replace this block with the original problem statement in LaTeX.`.

**Validacion Manual (solo si no hay tests automatizados):**
- Escenario 1: scaffold una nueva demo y verificar que el `.tex` creado trae un
  bloque para el problema original.
- Escenario 2: compilar el blueprint del demo actual y confirmar que el nuevo
  macro/entorno no rompe la salida PDF.
- Evidencia capturada en: salida de `pytest`, `scripts/build_blueprint_pdf.sh`
  y revision de diff.
  - Resultado ejecutado: validacion equivalente realizada en una replica segura
    en `/tmp/mimate_plan03_validation_min` para no modificar los artefactos
    actuales de `blueprint/library/pdf/` del repo principal.

**Plan de Rollback:**
- Trigger: el nuevo bloque degrada la maquetacion, rompe builds LaTeX o no es
  suficientemente explicito para el flujo `olympiad-formalize`.
- Acciones:
  - Revertir el macro/entorno y el placeholder del scaffold.
  - Restaurar las instrucciones previas de las skills si la integracion no fue estable.
  - Revalidar `pytest` y `scripts/build_blueprint_pdf.sh`.
- Verificacion posterior: el scaffold vuelve a su estado previo y el PDF compila
  sin el bloque de problema.
  - Validacion del rollback: el cambio es acotado a macros, scaffold y skill docs;
    no toca datos ni pruebas Lean existentes, por lo que revertir estos archivos
    y rerunear las mismas validaciones restablece el estado previo.

**Comandos Relevantes:**
- `.venv/bin/pytest -q tests/test_demo_library.py tests/test_blueprint_paper.py` - validar la logica Python tocada.
- `scripts/build_blueprint_pdf.sh` - validar que el flujo real del PDF sigue operativo.
- `git diff -U3` - revisar el alcance exacto del cambio.
- Fallback si faltan herramientas/skills: inspeccion manual del template TeX y
  build local del blueprint con el demo actual.

**Trazabilidad (links):**
- Issue/Ticket: [N/A]
- PR/Commit: [N/A]
- Decision(es) relacionada(s): [N/A por ahora]

**Sincronizacion con PROGRESS.md (si existe):**
- Modo de seguimiento activo: [Estandar]
- Ultimo sync confirmado: [2026-04-04T05:56:51.987+0000]
- Divergencias detectadas: [Ninguna]

**Estado Actual:** [Completado]
**Ultima Actualizacion:** [2026-04-04T05:56:51.987+0000]

---

## [PLAN-20260404-01] [Unificar el formato Lean del Glossary con el Anexo en el PDF blueprint]

**Plan ID:** [PLAN-20260404-01] (debe coincidir con el encabezado de la seccion)
**Objetivo General:** Cambiar la generacion del `Lean Glossary` para que su
contenido se renderice con la misma estrategia tipografica/sintactica del
`Anexo` usando macros TeX basadas en `minted`, revisando el pipeline completo de
build para evitar errores de rutas, escaping o regresiones de pruebas.
**Owner:** [Codex]
**Fecha de inicio:** [2026-04-04]
**Estado de aprobacion:** [Aprobado]
**Aprobado por:** [Usuario (chat)]
**Timestamp de aprobacion:** [2026-04-04T06:19:39.000+0000]
**Evidencia de aprobacion (chat/referencia):** [Conversacion actual: mensaje del usuario "Apruebo el plan"]
**Evidencia de /plan:** [no interactivo/sin slash commands: `codex exec --skip-git-repo-check --json "Analiza el flujo de generacion de blueprint PDF en este repositorio y produce un plan breve en 3 fases para cambiar el Lean Glossary de modo que renderice fragmentos Lean con la misma estrategia tipografica/sintactica del Anexo, minimizando riesgo de errores en LaTeX, rutas y tests. No ejecutes cambios; solo planifica." </dev/null` ejecutado el 2026-04-04; `thread_id=019d5721-e8ac-7773-964e-7f852b925474`; evidencia visible en la sesion actual con eventos `item.completed` sobre `tools/blueprint_paper.py`, `blueprint/src/macros/common.tex`, `scripts/build_blueprint_pdf.sh`, `README.md` y `tests/test_blueprint_paper.py`; referencia oficial: https://developers.openai.com/codex/noninteractive/#make-output-machine-readable]

**Aplicabilidad de esta skill (no pequena):**
- [x] Cumple al menos 2 criterios de no-pequena (pasos dependientes, impacto multi-modulo/componente critico, validacion no trivial).
- [x] No es tarea trivial de un solo paso.

**Alcance y Entregables:**
- Incluye: ajustar `tools/blueprint_paper.py` para que el glossary deje de
  escribir firmas escapadas en linea y pase a generar snippets `.lean`
  auxiliares renderizados desde `lean_glossary.tex`; reutilizar la estrategia
  TeX del `Anexo` via `\leaninputfile`; revisar si `blueprint/src/macros/common.tex`
  necesita un macro dedicado para snippets cortos; ampliar
  `tests/test_blueprint_paper.py`; validar con `pytest` y con al menos un build
  real de `scripts/build_blueprint_pdf.sh`.
- Excluye: cambiar la estructura del repo; tocar demostraciones `.lean` del
  usuario; modificar el contenido matematico del paper; alterar el `Anexo` mas
  alla de reutilizar su mecanismo; rehacer el estilo visual global del PDF.

**Supuestos:**
- El `Lean Glossary` debe seguir mostrando el nombre corto enlazable de cada
  declaracion, pero el bloque de contenido debe usar el mismo mecanismo Lean del
  `Anexo`.
- El lexer efectivo sigue resolviendose con `resolve_minted_config()` y debe
  compartirse entre glossary y annex.
- Los snippets del glossary pueden ser artefactos temporales dentro de
  `blueprint/build/<timestamp>_<stem>/` igual que `lean_glossary.tex` y
  `lean_appendix.tex`.

**Dependencias:**
- Python del repo: `.venv/bin/python`.
- Pygments/minted ya usados por el pipeline actual del `Anexo`.
- Archivos/puntos de integracion principales: `tools/blueprint_paper.py`,
  `blueprint/src/macros/common.tex`, `tests/test_blueprint_paper.py`,
  `scripts/build_blueprint_pdf.sh`.

**Tipo de tarea:** [Codigo]
**Nivel de riesgo/complejidad:** [Medio]
**Modo de planificacion:** [Completo (2-3 alternativas)]
**Origen de alternativas:** [Analisis manual en PLANS.md + evidencia de planificacion no interactiva]
**Justificacion del modo elegido:** El cambio toca la tuberia Python, la capa TeX
  y la compilacion real del PDF; una alternativa apresurada puede romper rutas
  relativas, escaping LaTeX o los tests que fijan el contrato actual.
**Modo de seguimiento en `PROGRESS.md`:** [Estandar]
**Justificacion del modo de seguimiento:** El trabajo tiene hitos claros
  (refactor del generador, ajuste TeX, validacion automatica/real) y conviene
  sincronizar al cierre de cada paso sin llevar bitacora estricta.

**Definicion de Hecho (DoD) - marcar solo criterios aplicables al tipo de tarea:**
- [x] Tipo de tarea declarado y consistente con el alcance.
- [x] (`Codigo` o `Mixta`) Suites relevantes ejecutadas en verde:
  `.venv/bin/pytest -q tests/test_blueprint_paper.py`.
- [ ] (`Codigo` o `Mixta`) Si no hay tests aplicables, validacion manual reproducible documentada.
- [x] Revision de cambios cerrada sin hallazgos bloqueantes (`Critico`/`Alto`).
- [x] Hallazgos clasificados con rubrica de severidad cuando la herramienta no reporta severidad explicita.
- [x] Documentacion actualizada en: `PLANS.md`, `PROGRESS.md` (si aplica), `README.md` (si aplica).
- [x] Criterios de aceptacion funcional cumplidos:
  - [x] [CA-1] `lean_glossary.tex` deja de usar `\leanstatement{...}` para firmas y
    pasa a incluir snippets Lean con la misma estrategia de `minted` usada por
    el `Anexo`.
  - [x] [CA-2] La generacion del PDF sigue resolviendo correctamente rutas relativas
    desde `blueprint/build/<...>/` hacia los snippets del glossary.
  - [x] [CA-3] El build real `scripts/build_blueprint_pdf.sh` completa sin errores
    de LaTeX/Pygments con el demo actual.
  - [x] [CA-4] Los tests reflejan el nuevo contrato del glossary y quedan en verde.
- [x] Rollback definido y validado (si aplica).

**Criterios minimos de salida (para estado `Completado`):**
- [x] No hay bloqueantes abiertos (funcionales, seguridad o tests).
- [x] Los checks DoD aplicables estan marcados como cumplidos.
- [x] Existe evidencia verificable de validacion (comandos, logs, diff o commit).

**Riesgos Identificados y Mitigaciones:**
- Riesgo: rutas relativas incorrectas desde `lean_glossary.tex` a snippets
  auxiliares dentro del build temporal.
  - Mitigacion: generar rutas con `relative_tex_path()`/`latex_detokenize()` y
    cubrirlo con pruebas unitarias.
- Riesgo: declaraciones con Unicode, `_` o firmas multilinea fallen al pasar de
  texto escapado a snippets `.lean`.
  - Mitigacion: escribir snippets en archivos UTF-8 y dejar a `minted` manejar
    el contenido, evitando escaping manual del codigo Lean.
- Riesgo: el fallback cuando no se encuentra una firma se degrade y rompa el
  PDF si la declaracion no existe localmente.
  - Mitigacion: mantener un fallback seguro, pero escribirlo como snippet Lean
    valido/minimo o como texto controlado dentro del flujo TeX.
- Riesgo: regressiones en spacing o anchors del glossary.
  - Mitigacion: conservar `\hypertarget{...}` y el encabezado corto enlazable,
    cambiando solo el bloque del contenido.

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
- Alternativa A: generar snippets `.lean` del glossary en el build temporal y
  renderizarlos con `\leaninputfile`, reutilizando el lexer y el estilo del
  `Anexo`.
  - Score por criterio: [A=5 S=4 R=4 T=5 M=5]
  - Puntaje total ponderado: [91/100]
- Alternativa B: ampliar `\leanstatement` para imitar visualmente el `Anexo`
  sin usar `minted` ni archivos auxiliares.
  - Score por criterio: [A=3 S=4 R=3 T=3 M=3]
  - Puntaje total ponderado: [64/100]
- Alternativa C: insertar bloques `minted` inline dentro de `lean_glossary.tex`
  generando el codigo directamente desde Python.
  - Score por criterio: [A=4 S=2 R=2 T=3 M=2]
  - Puntaje total ponderado: [52/100]

**Plan Seleccionado (resumen):**
Elegir la alternativa A. Es la unica que realmente reutiliza la misma
estrategia del `Anexo`, minimiza escaping manual de LaTeX y deja el estilo Lean
centralizado en macros TeX. Tambien permite probar rutas y contenido de forma
determinista sin alterar el paper ni el codigo fuente de las demostraciones.

## Pasos del Plan

- [x] STEP-01: Refactorizar el modelo/render del glossary para producir snippets
  Lean auxiliares en el build temporal.
  - Evidencia/resultado esperado: `tools/blueprint_paper.py` genera, por cada
    entrada del glossary, un archivo `.lean` o equivalente temporal y
    `lean_glossary.tex` lo referencia con la misma via de `minted` del `Anexo`.
  - Validacion: `.venv/bin/pytest -q tests/test_blueprint_paper.py -k glossary`
  - Artefacto esperado: `tools/blueprint_paper.py`, `tests/test_blueprint_paper.py`
  - Evidencia capturada: `render_lean_glossary()` ahora escribe snippets bajo
    `build/lean_glossary/` y los incluye con `\leaninputfile{<lexer>}{...}`;
    los nombres de snippet usan el label del glossary para evitar colisiones de
    `short_name` como `of_dvd`; `.venv/bin/pytest -q tests/test_blueprint_paper.py`
    cubre el render del glossary y el caso de nombres duplicados.
- [x] STEP-02: Ajustar la capa TeX para que el glossary use la estrategia del
  `Anexo` sin perder anchors ni legibilidad.
  - Evidencia/resultado esperado: `common.tex` conserva/reutiliza un macro claro
    para bloques Lean cortos y `lean_glossary.tex` sigue exponiendo
    `\hypertarget{...}` + nombre corto enlazable.
  - Validacion: inspeccion del `.tex` generado y `pytest` sobre el texto esperado.
  - Artefacto esperado: `blueprint/src/macros/common.tex` solo si hace falta,
    mas ajustes en `tests/test_blueprint_paper.py`.
  - Evidencia capturada: el macro `\leaninputfile` en
    `blueprint/src/macros/common.tex` se endurecio con `breakanywhere` y se
    simplifico quitando `frame`/`bgcolor` para evitar el error LaTeX
    `Dimension too large` observado al renderizar anexos grandes; los anchors
    `\hypertarget{...}` del glossary permanecen intactos.
- [x] STEP-03: Ejecutar validacion automatica y build real del blueprint para
  asegurar que no aparecen errores de LaTeX, rutas o Pygments.
  - Evidencia/resultado esperado: tests en verde y `scripts/build_blueprint_pdf.sh`
    completando con exit 0 sobre el demo actual.
  - Validacion: `.venv/bin/pytest -q tests/test_blueprint_paper.py`,
    `scripts/build_blueprint_pdf.sh`, `git diff -U3`.
  - Artefacto esperado: evidencia reproducible documentada en `PLANS.md` y, tras
    aprobacion, sincronizacion con `PROGRESS.md`.
  - Evidencia capturada: `.venv/bin/pytest -q tests/test_blueprint_paper.py`
    -> `15 passed`; `scripts/build_blueprint_pdf.sh` -> exit 0 con build final en
    `blueprint/build/20260404_002550_Demo_20260403_172608_n_good_polynomials`
    y PDF archivado en `blueprint/library/pdf/Demo_20260403_172608_n_good_polynomials.pdf`;
    revision manual de `git diff -U3` sin hallazgos `Critico`/`Alto`.

**Validacion Manual (solo si no hay tests automatizados):**
- Escenario 1: generar `lean_glossary.tex` en un `tmp_path` y confirmar que
  referencia snippets Lean relativos en lugar de `\leanstatement`.
- Escenario 2: correr `scripts/build_blueprint_pdf.sh` y confirmar que el PDF
  compila con el glossary renderizado mediante `minted`.

**Plan de Rollback:**
- Trigger: el glossary deja de compilar, aparecen rutas rotas o el nuevo
  formato vuelve ilegible el PDF.
- Acciones:
  - Revertir el render del glossary al esquema previo con `\leanstatement`.
  - Eliminar cualquier macro auxiliar nuevo si no aporta estabilidad.
  - Reejecutar `pytest` y el build del blueprint para confirmar restauracion.
- Verificacion posterior: el glossary vuelve a su salida anterior y el PDF
  compila sin depender de snippets auxiliares.
  - Validacion del rollback: los cambios quedan acotados a `tools/blueprint_paper.py`,
    `tests/test_blueprint_paper.py` y `blueprint/src/macros/common.tex`; revertir
    esos archivos y rerunear `pytest` + `scripts/build_blueprint_pdf.sh`
    restablece el comportamiento previo.

**Comandos Relevantes:**
- `.venv/bin/pytest -q tests/test_blueprint_paper.py` - validar el contrato del generador.
- `scripts/build_blueprint_pdf.sh` - verificar la tuberia real del PDF.
- `scripts/check_blueprint_decls.sh` - confirmar que el paper sigue referenciando declaraciones validas.
- `git diff -U3` - revisar el alcance exacto del cambio.
- Fallback si faltan herramientas/skills: inspeccion manual de `lean_glossary.tex`
  generado y build local del blueprint del demo actual.

**Trazabilidad (links):**
- Issue/Ticket: [N/A]
- PR/Commit: [N/A]
- Decision(es) relacionada(s): [N/A por ahora]

**Sincronizacion con PROGRESS.md (si existe):**
- Modo de seguimiento activo: [Estandar]
- Ultimo sync confirmado: [2026-04-04T06:26:27.349+0000]
- Divergencias detectadas: [Ninguna]

**Estado Actual:** [Completado]
**Ultima Actualizacion:** [2026-04-04T06:26:27.349+0000]

---
## [PLAN-20260416-01] Integracion operativa de busqueda Lean

**Plan ID:** PLAN-20260416-01
**Objetivo General:** Cerrar la ruta operativa de descubrimiento de declaraciones para `Mathlib` y `Biblioteca`, unificando docs y skills, y agregando un health-check reproducible para `loogle` local.
**Owner:** Codex
**Fecha de inicio:** 2026-04-16
**Estado de aprobacion:** Aprobado
**Aprobado por:** Usuario (chat)
**Timestamp de aprobacion:** 2026-04-17T02:20:42.000+0000
**Evidencia de aprobacion (chat/referencia):** Mensajes del usuario: "Adelante" y luego "Adelante, ejecuta este plan" en esta sesion.
**Evidencia de /plan:** Planificacion no interactiva registrada en chat y mediante la herramienta `update_plan` de esta sesion; no hubo slash commands disponibles.

**Aplicabilidad de esta skill (no pequena):**
- [x] Cumple al menos 2 criterios de no-pequena (pasos dependientes, impacto multi-modulo/componente critico, validacion no trivial).
- [x] No es tarea trivial de un solo paso.

**Alcance y Entregables:**
- Incluye: actualizar `README.md`, `docs/mathlib-exploration.md`, los skills Lean relevantes, agregar `scripts/check_loogle_local.sh`, y sumar tests Python minimos para el servidor local de `loogle`.
- Excluye: estabilizar el agregado global de `Biblioteca`, corregir demostraciones Lean rotas, o redisenar la arquitectura del servidor local.

**Supuestos:**
- El flujo recomendado del repo debe priorizar primitives de Lean, `rg` y `loogle` local antes de `lean4export` o LeanExplore.
- `Biblioteca` sigue siendo consultable por modulo, no como corpus global estable.

**Dependencias:**
- `rg`, `curl`, `rsync`, `.venv/bin/python`, `$HOME/.elan/bin/lake`.
- Scripts existentes: `scripts/build_loogle_local.sh`, `scripts/loogle_local.sh`, `scripts/start_loogle_local_server.sh`.

**Tipo de tarea:** Mixta
**Nivel de riesgo/complejidad:** Medio
**Modo de planificacion:** Completo (2-3 alternativas)
**Origen de alternativas:** Analisis manual en chat y `PLANS.md`
**Justificacion del modo elegido:** El trabajo toca documentacion, skills, shell scripts y Python, y requiere validacion cruzada sin alterar la estructura base del repo.
**Modo de seguimiento en `PROGRESS.md`:** No aplica (sin `PROGRESS.md`)
**Justificacion del modo de seguimiento:** La trazabilidad del cambio queda suficientemente cubierta en este plan y la tarea no requiere bitacora separada.

**Definicion de Hecho (DoD) - marcar solo criterios aplicables al tipo de tarea:**
- [x] Tipo de tarea declarado y consistente con el alcance.
- [x] (`Codigo` o `Mixta`) Suites relevantes ejecutadas en verde: `.venv/bin/python -m pytest -q`.
- [x] (`Codigo` o `Mixta`) Si no hay tests aplicables, validacion manual reproducible documentada.
- [x] (`Documentacion`) Exactitud tecnica verificada y enlaces/comandos validados.
- [x] (`Configuracion/DevEx` u `Operacion/Infra`) Validacion reproducible ejecutada y documentada.
- [x] Revision de cambios cerrada sin hallazgos bloqueantes (`Critico`/`Alto`).
- [x] Hallazgos clasificados con rubrica de severidad cuando la herramienta no reporta severidad explicita.
- [x] Documentacion actualizada en: `README.md`, `docs/mathlib-exploration.md`.
- [x] Criterios de aceptacion funcional cumplidos: `CA-1`, `CA-2`, `CA-3`.

**Criterios minimos de salida (para estado `Completado`):**
- [x] No hay bloqueantes abiertos (funcionales, seguridad o tests).
- [x] Los checks DoD aplicables estan marcados como cumplidos.
- [x] Existe evidencia verificable de validacion (comandos, logs, diff o commit).

**Riesgos Identificados y Mitigaciones:**
- Riesgo: romper cambios locales ya presentes en docs/skills.
  - Mitigacion: editar solo secciones puntuales y revisar el diff antes de cerrar.
- Riesgo: que el health-check dependa de red o permisos de loopback del entorno.
  - Mitigacion: separar validacion shell y validacion de socket; documentar cualquier limitacion restante.

**Alternativas Evaluadas y Rubrica:**
- Alternativa A: corregir solo docs.
  - Score por criterio: [A=2 S=5 R=4 T=2 M=2]
  - Puntaje total ponderado: 61/100
- Alternativa B: docs + skills + health-check + tests minimos.
  - Score por criterio: [A=5 S=4 R=4 T=5 M=5]
  - Puntaje total ponderado: 91/100
- Alternativa C: redisenar ademas el indexado global de `Biblioteca`.
  - Score por criterio: [A=3 S=1 R=1 T=2 M=2]
  - Puntaje total ponderado: 35/100

**Plan Seleccionado (resumen):**
Ejecutar la alternativa B. Corrige la incoherencia operativa real del repo, deja una verificacion reproducible para `loogle` local y mantiene fuera de alcance la estabilizacion mas costosa de `Biblioteca`.

## Pasos del Plan

- [x] STEP-01: Unificar la ruta operativa en `README.md` y `docs/mathlib-exploration.md`.
  - Evidencia/resultado esperado: docs alineadas sobre el orden `Lean built-ins -> rg -> loogle -> lean4export -> LeanExplore`.
  - Validacion: `git diff -U3 -- README.md docs/mathlib-exploration.md`
  - Artefacto esperado: diff de documentacion.
- [x] STEP-02: Ajustar los skills Lean para usar el mismo orden operativo.
  - Evidencia/resultado esperado: `lean-prove`, `lean-verify` y `mimate-proof-strategy` mencionan built-ins, `scripts/check_loogle_local.sh` y el uso por modulo de `Biblioteca`.
  - Validacion: `git diff -U3 -- .agents/skills/lean-prove/SKILL.md .agents/skills/lean-verify/SKILL.md .agents/skills/mimate-proof-strategy/SKILL.md`
  - Artefacto esperado: diff de skills.
- [x] STEP-03: Agregar `scripts/check_loogle_local.sh` y tests Python minimos para el servidor local.
  - Evidencia/resultado esperado: script nuevo y test de `tools/loogle_local_server.py`.
  - Validacion: `bash -n scripts/check_loogle_local.sh` y `.venv/bin/python -m pytest -q`
  - Artefacto esperado: script y test.
- [x] STEP-04: Validar el cambio y dejar trazabilidad final en este plan.
  - Evidencia/resultado esperado: comandos de validacion ejecutados y estado final actualizado.
  - Validacion: `git diff -U3`, `.venv/bin/python -m pytest -q`
  - Artefacto esperado: evidencia en respuesta final.

**Validacion Manual (solo si no hay tests automatizados):**
- Escenario 1: `scripts/check_loogle_local.sh` detecta falta de bootstrap de `loogle` y emite mensaje accionable.
- Escenario 2: con el servidor local arriba, `scripts/check_loogle_local.sh` confirma salud del endpoint `/` y de `/json`.
- Evidencia capturada en:
  - `bash -n scripts/check_loogle_local.sh scripts/build_loogle_local.sh scripts/loogle_local.sh scripts/start_loogle_local_server.sh`
  - `.venv/bin/python -m pytest -q` -> `31 passed`
  - `scripts/check_loogle_local.sh` -> error accionable cuando el servidor no esta arriba
  - `scripts/check_loogle_local.sh --start` -> `Local loogle server is healthy at http://127.0.0.1:8088`

**Plan de Rollback:**
- Trigger: regresion en docs/skills o fallo del nuevo health-check.
- Acciones: revertir los cambios en docs/skills/script/test de este plan.
- Verificacion posterior: rerun de `.venv/bin/python -m pytest -q` y revision del diff.

**Comandos Relevantes:**
- `.venv/bin/python -m pytest -q` - validar tests Python.
- `bash -n scripts/check_loogle_local.sh scripts/build_loogle_local.sh scripts/loogle_local.sh scripts/start_loogle_local_server.sh` - validar shell scripts.
- `git diff -U3` - revisar el alcance exacto del parche.

**Trazabilidad (links):**
- Issue/Ticket: N/A
- PR/Commit: N/A
- Decision(es) relacionada(s): N/A

**Sincronizacion con PROGRESS.md (si existe):**
- Modo de seguimiento activo: No aplica
- Ultimo sync confirmado: N/A
- Divergencias detectadas: Ninguna

**Estado Actual:** Completado
**Ultima Actualizacion:** 2026-04-17T02:27:57.000+0000

---
## [PLAN-20260416-02] Verificacion final de servicio loogle

**Plan ID:** PLAN-20260416-02
**Objetivo General:** Verificar que el servicio local de `loogle` ya instalado este integrado con el proyecto y dejar documentado el arranque manual del servicio en la documentacion tecnica correspondiente.
**Owner:** Codex
**Fecha de inicio:** 2026-04-16
**Estado de aprobacion:** Aprobado
**Aprobado por:** Usuario (chat)
**Timestamp de aprobacion:** 2026-04-17T02:50:32.000+0000
**Evidencia de aprobacion (chat/referencia):** Mensaje del usuario: "Ya quedó instalado el servicio loogle, verifica que esté integrado con el proyecto, así como documentar como inciar el servicio para utilizarlo el el archivo correspondiente."
**Evidencia de /plan:** Planificacion no interactiva registrada en chat y mediante la herramienta `update_plan` de esta sesion; no hubo slash commands disponibles.

**Aplicabilidad de esta skill (no pequena):**
- [x] Cumple al menos 2 criterios de no-pequena (pasos dependientes, impacto multi-modulo/componente critico, validacion no trivial).
- [x] No es tarea trivial de un solo paso.

**Alcance y Entregables:**
- Incluye: verificar el health-check del servicio, confirmar la integracion con `LeanSearchClient` y documentar el arranque manual del servicio en `docs/mathlib-exploration.md`.
- Excluye: redisenar la arquitectura de `loogle`, cambiar el backend del servicio o estabilizar la busqueda global de `Biblioteca`.

**Tipo de tarea:** Mixta
**Nivel de riesgo/complejidad:** Medio
**Modo de planificacion:** Simplificado no-pequeno (1 alternativa + 1 descartada)
**Origen de alternativas:** Analisis manual en `PLANS.md`
**Justificacion del modo elegido:** Es una fase acotada de validacion y documentacion sobre una integracion ya implementada.
**Modo de seguimiento en `PROGRESS.md`:** No aplica (sin `PROGRESS.md`)
**Justificacion del modo de seguimiento:** La trazabilidad en `PLANS.md` es suficiente para esta fase corta.

**Definicion de Hecho (DoD) - marcar solo criterios aplicables al tipo de tarea:**
- [x] Tipo de tarea declarado y consistente con el alcance.
- [x] (`Codigo` o `Mixta`) Suites relevantes ejecutadas en verde: `scripts/check_loogle_local.sh`.
- [x] (`Codigo` o `Mixta`) Si no hay tests aplicables, validacion manual reproducible documentada.
- [x] (`Documentacion`) Exactitud tecnica verificada y enlaces/comandos validados.
- [x] (`Configuracion/DevEx` u `Operacion/Infra`) Validacion reproducible ejecutada y documentada.
- [x] Revision de cambios cerrada sin hallazgos bloqueantes (`Critico`/`Alto`).
- [x] Documentacion actualizada en: `docs/mathlib-exploration.md`.

**Alternativas Evaluadas y Rubrica:**
- Alternativa elegida: verificar la integracion real y documentar el arranque manual en la doc tecnica existente.
  - Justificacion: maximiza coherencia con el flujo ya documentado y evita duplicar instrucciones en archivos secundarios.
- Alternativa descartada: limitarse a revisar config y no ejecutar una verificacion real del servicio.
  - Justificacion: no prueba la integracion end-to-end con el proyecto.

## Pasos del Plan

- [x] STEP-01: Verificar el health-check y la respuesta del servicio local.
  - Validacion: `scripts/check_loogle_local.sh`
- [x] STEP-02: Verificar la integracion con `LeanSearchClient`/`#loogle`.
  - Validacion: consulta Lean contra la URL local configurada.
- [x] STEP-03: Documentar el arranque manual y uso del servicio.
  - Validacion: `git diff -U3 -- docs/mathlib-exploration.md`

**Validacion Manual (evidencia):**
- `scripts/check_loogle_local.sh --start` -> `Local loogle server is healthy at http://127.0.0.1:8088`
- Consulta Lean-side validada con:
  `LEANSEARCHCLIENT_LOOGLE_API_URL=http://127.0.0.1:8088/json /home/mario/.elan/bin/lake env /home/mario/.elan/bin/lean <tmpfile>`
- Salida observada: `Loogle Search Results` con `Nat.add_comm` como primer resultado.

**Estado Actual:** Completado
**Ultima Actualizacion:** 2026-04-17T02:50:32.000+0000

---
## [PLAN-20260416-03] [Fallback operativo de loogle con indice persistido]

**Plan ID:** [PLAN-20260416-03]
**Objetivo General:** Evitar que el flujo de exploracion con `loogle` quede bloqueado cuando el CLI tarda demasiado construyendo o cargando indice, agregando soporte repo-local para indices persistidos y documentando el fallback operativo en scripts, docs y skills.
**Owner:** [Codex]
**Fecha de inicio:** [2026-04-17]
**Estado de aprobacion:** [Aprobado]
**Aprobado por:** [Usuario (chat)]
**Timestamp de aprobacion:** [2026-04-17T04:06:17.000+0000]
**Evidencia de aprobacion (chat/referencia):** [Mensaje del usuario: "Apruebo el plan".]
**Evidencia de /plan:** [Planificacion interactiva registrada en chat y mediante `update_plan` en esta sesion; no hubo slash commands accesibles desde este entorno.]

**Aplicabilidad de esta skill (no pequena):**
- [x] Cumple al menos 2 criterios de no-pequena (pasos dependientes, impacto multi-modulo/componente critico, validacion no trivial).
- [x] No es tarea trivial de un solo paso.

**Alcance y Entregables:**
- Incluye: agregar un flujo repo-local para escribir y reutilizar indices persistidos de `loogle`, ajustar el wrapper/salud operativa para preferir `--read-index` cuando exista, y alinear docs/skills con el fallback esperado dentro de una sesion de Codex.
- Excluye: redisenar `loogle`, cambiar el backend del servidor local, o resolver la busqueda global sobre todo `Biblioteca`.

**Supuestos:**
- El problema principal es de experiencia operativa del agente, no de compatibilidad del binario de `loogle`.
- Para `Mathlib`, un indice persistido local puede acelerar el primer uso y evitar bloqueos percibidos en sandbox.
- Para `Biblioteca`, la busqueda sigue siendo principalmente por modulo, aunque el indice persistido pueda usarse si el modulo es estable.

**Dependencias:**
- `scripts/loogle_local.sh`, `scripts/check_loogle_local.sh`, `scripts/start_loogle_local_server.sh`.
- Fuente local de `loogle` en `.local-tools/loogle` y workspace compilado en `.local-tools/loogle-mimate`.
- `.venv/bin/python -m pytest -q` para regression checks del soporte Python ya existente.

**Tipo de tarea:** [Mixta]
**Nivel de riesgo/complejidad:** [Medio]
**Modo de planificacion:** [Completo (2-3 alternativas)]
**Origen de alternativas:** Analisis manual en chat, `PLANS.md` y codigo local del wrapper/CLI de `loogle`.
**Justificacion del modo elegido:** Toca varios scripts, skills y documentacion, con validacion shell y de comportamiento esperado del agente, pero sin requerir redisenos profundos.
**Modo de seguimiento en `PROGRESS.md`:** No aplica (sin `PROGRESS.md`)
**Justificacion del modo de seguimiento:** La trazabilidad en este plan es suficiente para un cambio operativo corto.

**Definicion de Hecho (DoD) - marcar solo criterios aplicables al tipo de tarea:**
- [x] Tipo de tarea declarado y consistente con el alcance.
- [x] (`Codigo` o `Mixta`) Suites relevantes ejecutadas en verde: `.venv/bin/python -m pytest -q`.
- [x] (`Codigo` o `Mixta`) Si no hay tests aplicables, validacion manual reproducible documentada.
- [x] (`Documentacion`) Exactitud tecnica verificada y comandos validados.
- [x] (`Configuracion/DevEx` u `Operacion/Infra`) Validacion reproducible ejecutada y documentada.
- [x] Revision de cambios cerrada sin hallazgos bloqueantes (`Critico`/`Alto`).
- [x] Documentacion actualizada en: `docs/mathlib-exploration.md` y skills Lean relevantes.

**Alternativas Evaluadas y Rubrica:**
- Alternativa A: documentar solo el fallback narrativo en skills/docs.
  - Score por criterio: [A=2 S=5 R=4 T=2 M=2]
  - Puntaje total ponderado: 59/100
- Alternativa B: agregar indice persistido repo-local y hacer que el wrapper lo use automaticamente cuando exista; alinear skills/docs con ese comportamiento.
  - Score por criterio: [A=5 S=4 R=4 T=5 M=5]
  - Puntaje total ponderado: 91/100
- Alternativa C: forzar siempre reconstruccion de indice en cada arranque del servidor o del wrapper.
  - Score por criterio: [A=3 S=1 R=2 T=3 M=2]
  - Puntaje total ponderado: 42/100

**Plan Seleccionado (resumen):**
Ejecutar la alternativa B. Deja una ruta reproducible para persistir el indice, permite reusar `--read-index` sin friccion cuando ya exista, y alinea el comportamiento esperado del agente con la documentacion del repo.

## Pasos del Plan

- [x] STEP-01: Agregar soporte repo-local para escribir y reutilizar indices persistidos de `loogle`.
  - Evidencia/resultado esperado: existe un script para construir indice y el wrapper usa `--read-index` cuando corresponde.
  - Validacion: `bash -n` sobre los scripts modificados y revison del diff.
- [x] STEP-02: Alinear docs y skills con el fallback operativo esperado dentro de Codex.
  - Evidencia/resultado esperado: la documentacion y los skills describen el mensaje/fallback correcto cuando `loogle` tarda demasiado.
  - Validacion: `git diff -U3 -- docs/mathlib-exploration.md .agents/skills/lean-prove/SKILL.md .agents/skills/lean-verify/SKILL.md .agents/skills/mimate-proof-strategy/SKILL.md`
- [x] STEP-03: Ejecutar validaciones y dejar trazabilidad final.
  - Evidencia/resultado esperado: shell scripts sin errores de sintaxis y `pytest` en verde.
  - Validacion: `bash -n ...` y `.venv/bin/python -m pytest -q`

**Validacion Manual (evidencia):**
- Escenario 1: si existe un indice persistido repo-local, `scripts/loogle_local.sh` debe preferirlo sin que el usuario pase `--read-index`.
- Escenario 2: si no existe ese indice, el wrapper debe seguir funcionando con el comportamiento actual.
- Escenario 3: docs/skills describen el fallback operativo: intentar indice persistido y, si no existe, seguir con `rg` y declaraciones ya localizadas.
- Evidencia capturada en:
  - `bash -n scripts/loogle_local.sh scripts/build_loogle_index.sh scripts/check_loogle_local.sh scripts/build_loogle_local.sh scripts/start_loogle_local_server.sh`
  - `./scripts/build_loogle_index.sh --help`
  - `./scripts/loogle_local.sh --help`
  - `.venv/bin/python -B -m pytest -q -p no:cacheprovider` -> `32 passed`
  - `validate-plan-approval.sh PLANS.md PLAN-20260416-03` -> gate valido

**Plan de Rollback:**
- Trigger: el wrapper deja de funcionar para consultas normales o el fallback introduce ambiguedad/documentacion incorrecta.
- Acciones: revertir cambios en scripts/docs/skills de este plan.
- Verificacion posterior: `bash -n` sobre scripts relevantes y `.venv/bin/python -m pytest -q`.

**Comandos Relevantes:**
- `bash -n scripts/loogle_local.sh scripts/check_loogle_local.sh scripts/build_loogle_local.sh` - validar shell.
- `.venv/bin/python -m pytest -q` - regression check del soporte Python.
- `git diff -U3` - revisar el alcance del cambio.

**Trazabilidad (links):**
- Issue/Ticket: N/A
- PR/Commit: N/A
- Decision(es) relacionada(s): N/A

**Sincronizacion con PROGRESS.md (si existe):**
- Modo de seguimiento activo: No aplica
- Ultimo sync confirmado: N/A
- Divergencias detectadas: Ninguna

**Estado Actual:** Completado
**Ultima Actualizacion:** 2026-04-17T04:13:11.000+0000

---
## [PLAN-20260417-01] [Endurecer uso explicito del indice Mathlib persistido en loogle]

**Plan ID:** [PLAN-20260417-01]
**Objetivo General:** Hacer que el repo use de forma explicita y consistente el indice persistido de `Mathlib` en `loogle`, por ruta absoluta y con `--read-index`, para evitar reconstrucciones innecesarias dentro de sesiones de Codex en sandbox.
**Owner:** [Codex]
**Fecha de inicio:** [2026-04-17]
**Estado de aprobacion:** [Aprobado]
**Aprobado por:** [Usuario (chat)]
**Timestamp de aprobacion:** [2026-04-18T02:05:06.000+0000]
**Evidencia de aprobacion (chat/referencia):** [Mensaje del usuario: "Apruebo el plan, con alternativa 2".]
**Evidencia de /plan:** [Planificacion interactiva registrada en chat y mediante `update_plan` en esta sesion; se contrasto ademas con la documentacion primaria de `loogle` (`README.md`) y Context7 para confirmar el uso recomendado de `--read-index` y `--write-index`.]

**Aplicabilidad de esta skill (no pequena):**
- [x] Cumple al menos 2 criterios de no-pequena (pasos dependientes, impacto multi-modulo/componente critico, validacion no trivial).
- [x] No es tarea trivial de un solo paso.

**Alcance y Entregables:**
- Incluye: endurecer `scripts/loogle_local.sh`, `tools/loogle_local_server.py`, `scripts/init.sh`, docs y skills para que el indice persistido de `Mathlib` se use por ruta absoluta cuando exista; revisar si esa es la tecnica correcta segun la documentacion de `loogle`; y alinear mensajes operativos con la experiencia observada en sandbox.
- Excluye: cambiar el formato del indice, redisenar el backend de `loogle`, o generalizar el mismo tratamiento explicito a toda `Biblioteca` mas alla del flujo actual por modulo.

**Supuestos:**
- El indice persistido canónico para `Mathlib` en este workspace es `/home/mario/code/mimate/.local-tools/loogle-indexes/Mathlib.extra`.
- Ese indice solo debe regenerarse cuando cambie la libreria `Mathlib`, no en cada sesion ni en cada consulta.
- La documentacion primaria de `loogle` considera valido `--read-index <file>` siempre que el caller garantice que el indice corresponde al modulo y al search path correctos.

**Dependencias:**
- Wrapper local de `loogle`: `scripts/loogle_local.sh`.
- Servicio JSON local: `tools/loogle_local_server.py`.
- Skills Lean y documentacion del repo.
- `.venv/bin/python -m pytest -q` para regression checks del soporte Python.

**Tipo de tarea:** [Mixta]
**Nivel de riesgo/complejidad:** [Medio]
**Modo de planificacion:** [Completo (2-3 alternativas)]
**Origen de alternativas:** [Analisis manual en chat, inspeccion del repo y documentacion primaria de `loogle`.]
**Justificacion del modo elegido:** [Toca scripts shell, un servicio Python, skills y documentacion. Requiere validar el comportamiento correcto de `--read-index` sin cambiar la arquitectura general.]
**Modo de seguimiento en `PROGRESS.md`:** [No aplica (sin `PROGRESS.md`)]
**Justificacion del modo de seguimiento:** [La trazabilidad en `PLANS.md` es suficiente para este ajuste acotado.]

**Definicion de Hecho (DoD) - marcar solo criterios aplicables al tipo de tarea:**
- [x] Tipo de tarea declarado y consistente con el alcance.
- [x] (`Codigo` o `Mixta`) Suites relevantes ejecutadas en verde: `.venv/bin/python -m pytest -q`.
- [x] (`Codigo` o `Mixta`) Si no hay tests aplicables, validacion manual reproducible documentada.
- [x] (`Documentacion`) Exactitud tecnica verificada y comandos validados.
- [x] (`Configuracion/DevEx` u `Operacion/Infra`) Validacion reproducible ejecutada y documentada.
- [x] Revision de cambios cerrada sin hallazgos bloqueantes (`Critico`/`Alto`).
- [x] Documentacion actualizada en: `README.md`, `docs/mathlib-exploration.md`, skills Lean relevantes.

**Alternativas Evaluadas y Rubrica:**
- Alternativa A: solo documentar la ruta absoluta del indice `Mathlib.extra`.
  - Score por criterio: [A=2 S=5 R=4 T=2 M=2]
  - Puntaje total ponderado: 58/100
- Alternativa B: endurecer scripts, servicio, docs y skills para usar de forma explicita `--read-index /home/mario/code/mimate/.local-tools/loogle-indexes/Mathlib.extra` cuando aplique.
  - Score por criterio: [A=5 S=4 R=4 T=5 M=5]
  - Puntaje total ponderado: 91/100
- Alternativa C: cambiar el flujo a una estrategia distinta basada solo en `LoogleMathlibCache`.
  - Score por criterio: [A=3 S=2 R=2 T=3 M=3]
  - Puntaje total ponderado: 50/100

**Plan Seleccionado (resumen):**
Ejecutar la alternativa B. Es la que mejor refleja la experiencia real observada en sandbox, coincide con la documentacion primaria de `loogle` sobre `--read-index`, y deja un comportamiento mas determinista para `Mathlib`.

## Pasos del Plan

- [x] STEP-01: Hacer explicito el uso del indice persistido de `Mathlib` en wrapper, servicio e inicio de sesion.
  - Evidencia/resultado esperado: los procesos del repo usan o anuncian la ruta absoluta `/home/mario/code/mimate/.local-tools/loogle-indexes/Mathlib.extra` cuando corresponde.
  - Validacion: `bash -n` sobre scripts modificados y tests Python del servidor.
- [x] STEP-02: Alinear docs y skills con el comando explicito de `--read-index` para `Mathlib`.
  - Evidencia/resultado esperado: la doc y los skills recomiendan la ruta absoluta del indice `Mathlib.extra` y aclaran que solo se regenera cuando cambia `Mathlib`.
  - Validacion: `git diff -U3 -- README.md docs/mathlib-exploration.md .agents/skills/lean-prove/SKILL.md .agents/skills/lean-verify/SKILL.md .agents/skills/mimate-proof-strategy/SKILL.md`
- [x] STEP-03: Validar el cambio y cerrar trazabilidad.
  - Evidencia/resultado esperado: shell scripts validos, tests en verde y plan actualizado.
  - Validacion: `bash -n ...`, `.venv/bin/python -m pytest -q`, `git diff -U3`

**Validacion Manual (evidencia):**
- Escenario 1: una consulta `Mathlib` desde el wrapper o el servicio usa explicitamente el indice persistido si `/home/mario/code/mimate/.local-tools/loogle-indexes/Mathlib.extra` existe.
- Escenario 2: la documentacion del repo deja claro que ese indice solo se regenera cuando cambia `Mathlib`.
- Escenario 3: si el indice no existe, el fallback sigue siendo explicito y accionable.
- Evidencia capturada en:
  - `validate-plan-approval.sh PLANS.md PLAN-20260417-01` -> gate valido
  - `bash -n scripts/loogle_local.sh scripts/build_loogle_index.sh scripts/check_loogle_local.sh scripts/init.sh scripts/start_loogle_local_server.sh`
  - `./scripts/build_loogle_index.sh --help`
  - `./scripts/loogle_local.sh --help`
  - `.venv/bin/python -B -m pytest -q -p no:cacheprovider` -> `34 passed`
  - revision manual del diff y de las lineas clave en `scripts/loogle_local.sh`, `scripts/build_loogle_index.sh`, `scripts/init.sh`, `tools/loogle_local_server.py`, `tests/test_loogle_local_server.py`, `docs/mathlib-exploration.md`

**Plan de Rollback:**
- Trigger: el endurecimiento rompe consultas normales de `loogle` o vuelve inconsistente el flujo por modulo.
- Acciones: revertir cambios de este plan en scripts, servicio, docs y skills.
- Verificacion posterior: `bash -n` + `.venv/bin/python -m pytest -q`.

**Comandos Relevantes:**
- `bash -n scripts/loogle_local.sh scripts/build_loogle_index.sh scripts/check_loogle_local.sh scripts/init.sh` - validar shell.
- `.venv/bin/python -m pytest -q` - regression check del soporte Python.
- `git diff -U3` - revisar el alcance del cambio.

**Trazabilidad (links):**
- Issue/Ticket: [N/A]
- PR/Commit: [N/A]
- Decision(es) relacionada(s): [N/A]

**Sincronizacion con PROGRESS.md (si existe):**
- Modo de seguimiento activo: [No aplica]
- Ultimo sync confirmado: [N/A]
- Divergencias detectadas: [Ninguna]

**Estado Actual:** [Completado]
**Ultima Actualizacion:** [2026-04-18T02:20:21.000+0000]

---

## [PLAN-20260418-01] [Reducir advertencias tipograficas del builder PDF]

**Plan ID:** [PLAN-20260418-01] (debe coincidir con el encabezado de la seccion)
**Objetivo General:** Corregir la generacion del PDF blueprint para eliminar las
advertencias tipograficas no fatales observadas en la compilacion reciente,
especialmente el caracter Unicode `≥` en metadatos, los `overfull hbox`
provocados por referencias Lean largas y el ruido recurrente del layout del
glossary/anexo.
**Owner:** [Codex]
**Fecha de inicio:** [2026-04-18]
**Estado de aprobacion:** [Aprobado]
**Aprobado por:** [Usuario (chat)]
**Timestamp de aprobacion:** [2026-04-18T12:50:11.146+0000]
**Evidencia de aprobacion (chat/referencia):** [Conversacion actual: mensaje del usuario "Apruebo el plan"]
**Evidencia de /plan:** [no interactivo/sin slash commands: planificacion registrada en esta sesion mediante inspeccion del repo + `update_plan` antes de implementar; evidencia visible en la sesion actual con pasos "Inspeccionar builder PDF, macros TeX y logs..." y "Definir alternativas y plan de cambio para el pipeline PDF"; referencia oficial: https://developers.openai.com/codex/noninteractive/]

**Aplicabilidad de esta skill (no pequena):**
- [x] Cumple al menos 2 criterios de no-pequena (pasos dependientes, impacto multi-modulo/componente critico, validacion no trivial).
- [x] No es tarea trivial de un solo paso.

**Alcance y Entregables:**
- Incluye: ajustar el builder Python del PDF, las macros TeX comunes y las
  pruebas del pipeline para sanear metadatos, permitir cortes de linea en
  referencias Lean largas y reducir las advertencias tipograficas del build real.
- Excluye: cambiar el contenido matematico de las demostraciones, editar el
  archivo `.tex` del demo actual como solucion puntual, migrar de motor TeX o
  alterar la estructura general del blueprint.

**Supuestos:**
- El warning del caracter `≥` proviene de metadatos inyectados en `paper.tex`
  como texto normal, no de contenido matematico del cuerpo del paper.
- Las referencias `\lean{...}` deben seguir siendo enlazables y mostrarse con el
  nombre corto, pero necesitan un renderizado mas flexible para no forzar cajas
  demasiado anchas.
- El builder actual con `XeLaTeX + minted` debe mantenerse; el objetivo es
  corregir la entrada y la maquetacion, no silenciar warnings de forma global.

**Dependencias:**
- Archivos afectados previstos:
  - `tools/blueprint_paper.py`
  - `blueprint/src/macros/common.tex`
  - `blueprint/src/macros/print.tex` (si hace falta ajustar hyperref/layout)
  - `tests/test_blueprint_paper.py`
- Validaciones relevantes:
  - `.venv/bin/pytest -q tests/test_blueprint_paper.py`
  - `scripts/build_blueprint_pdf.sh`

**Tipo de tarea:** [Codigo]
**Nivel de riesgo/complejidad:** [Medio]
**Modo de planificacion:** [Completo (2-3 alternativas)]
**Origen de alternativas:** [Analisis manual en PLANS.md]
**Justificacion del modo elegido:** El cambio toca el pipeline oficial de build,
cruza Python y TeX, y necesita validacion automatica y real del PDF; una
solucion local al documento o un silenciamiento de warnings seria insuficiente.
**Modo de seguimiento en `PROGRESS.md`:** [Estandar]
**Justificacion del modo de seguimiento:** Hay hitos claros de ejecucion
(trazabilidad inicial, implementacion, validacion) y conviene dejar sincronizada
la bitacora sin llegar a un seguimiento estricto por subpaso.

**Definicion de Hecho (DoD) - marcar solo criterios aplicables al tipo de tarea:**
- [x] Tipo de tarea declarado y consistente con el alcance.
- [x] (`Codigo` o `Mixta`) Suites relevantes ejecutadas en verde: `.venv/bin/pytest -q tests/test_blueprint_paper.py`, `scripts/build_blueprint_pdf.sh`.
- [x] (`Codigo` o `Mixta`) Si no hay tests aplicables, validacion manual reproducible documentada.
- [x] Revision de cambios cerrada sin hallazgos bloqueantes (`Critico`/`Alto`).
- [x] Hallazgos clasificados con rubrica de severidad cuando la herramienta no reporta severidad explicita.
- [x] Documentacion actualizada en: `PLANS.md`, `PROGRESS.md`.
- [x] Criterios de aceptacion funcional cumplidos:
  - [CA-1] El build real del PDF ya no emite el warning `Missing character: There is no ≥ ...`.
  - [CA-2] Las referencias Lean largas del cuerpo/glossary ya no producen `overfull/underfull` tipograficos en el caso reproducido.
  - [CA-3] El pipeline sigue compilando con `XeLaTeX` y mantiene el output archivado habitual.
- [x] Rollback definido y validado (si aplica).

**Criterios minimos de salida (para estado `Completado`):**
- [x] No hay bloqueantes abiertos (funcionales, seguridad o tests).
- [x] Los checks DoD aplicables estan marcados como cumplidos.
- [x] Existe evidencia verificable de validacion (comandos, logs, diff o commit).

**Riesgos Identificados y Mitigaciones:**
- Riesgo: sanear metadatos de forma demasiado agresiva y deformar el contenido
  del abstract o keywords.
  - Mitigacion: limitar el cambio a texto usado en `\title`, `\abstract`,
    `\keywords` y bookmarks PDF, con pruebas unitarias para los casos con
    operadores matematicos comunes.
- Riesgo: permitir saltos de linea en referencias Lean y romper enlaces o el
  render del glossary.
  - Mitigacion: conservar la estructura de hipervinculo y cubrir el nuevo
    contrato con pruebas en `tests/test_blueprint_paper.py`.
- Riesgo: seguir teniendo warnings del anexo por limites de `minted`.
  - Mitigacion: ajustar el layout minimo en macros comunes y validar sobre el
    caso real antes de cerrar el plan.

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
- Alternativa A: corregir el pipeline Python/TeX para sanear metadatos, mejorar
  `\lean{...}` y ajustar el layout del anexo/glossary.
  - Score por criterio: [A=5 S=4 R=4 T=5 M=5]
  - Puntaje total ponderado: [91/100]
- Alternativa B: silenciar warnings de LaTeX o relajar umbrales sin tocar la
  causa real.
  - Score por criterio: [A=2 S=5 R=2 T=2 M=2]
  - Puntaje total ponderado: [49/100]
- Alternativa C: editar solo el `.tex` del demo actual para quitar `\ge` y
  acortar nombres largos.
  - Score por criterio: [A=2 S=4 R=4 T=2 M=1]
  - Puntaje total ponderado: [49/100]

**Plan Seleccionado (resumen):**
Ejecutar la alternativa A. Corrige la causa en la ruta oficial de build, mejora
la estabilidad del pipeline para futuros demos y deja pruebas que fijan el
comportamiento esperado.

## Pasos del Plan

- [x] STEP-01: Introducir trazabilidad, helpers y pruebas para metadatos y referencias Lean.
  - Evidencia/resultado esperado: el builder puede normalizar metadatos
    problematicos y las pruebas describen el nuevo contrato.
  - Validacion: `.venv/bin/pytest -q tests/test_blueprint_paper.py`
  - Artefacto esperado: cambios en `tools/blueprint_paper.py` y `tests/test_blueprint_paper.py`
- [x] STEP-02: Ajustar macros TeX para permitir mejor corte de linea y reducir ruido tipografico del PDF.
  - Evidencia/resultado esperado: las macros comunes soportan referencias Lean
    largas y mejor spacing del anexo/glossary.
  - Validacion: `git diff -U3 -- tools/blueprint_paper.py blueprint/src/macros/common.tex blueprint/src/macros/print.tex tests/test_blueprint_paper.py`
  - Artefacto esperado: cambios en macros TeX y, si aplica, en el generador del paper.
- [x] STEP-03: Validar el build real del PDF y cerrar trazabilidad.
  - Evidencia/resultado esperado: el caso reproducido compila sin el warning del
    caracter `≥` y con menos warnings de cajas.
  - Validacion: `scripts/build_blueprint_pdf.sh`, revision del `paper.log`, `git diff -U3`
  - Artefacto esperado: plan y progreso actualizados con evidencia final.

**Validacion Manual (solo si no hay tests automatizados):**
- Escenario 1: generar el PDF del demo actual y confirmar que el log ya no
  contiene `Missing character: There is no ≥`.
- Escenario 2: verificar que el log del caso reproducido ya no reporta
  `Overfull \hbox`, `Underfull \hbox` ni `Underfull \vbox` en los bloques que antes desbordaban.
- Evidencia capturada en:
  - `.venv/bin/pytest -q tests/test_blueprint_paper.py` -> `16 passed`
  - `scripts/build_blueprint_pdf.sh` -> `Build directory: /home/mario/code/mimate/blueprint/build/20260418_082009_Demo_20260403_172608_n_good_polynomials`
  - `rg -n -F "Missing character: There is no ≥" blueprint/build/20260418_082009_Demo_20260403_172608_n_good_polynomials/paper.log` -> sin coincidencias
  - `rg -n -F "Token not allowed in a PDF string" blueprint/build/20260418_082009_Demo_20260403_172608_n_good_polynomials/paper.log` -> sin coincidencias
  - `rg -n -F "Overfull \hbox" blueprint/build/20260418_082009_Demo_20260403_172608_n_good_polynomials/paper.log` -> sin coincidencias
  - `rg -n -F "Underfull \hbox" blueprint/build/20260418_082009_Demo_20260403_172608_n_good_polynomials/paper.log` -> sin coincidencias
  - `rg -n -F "Underfull \vbox" blueprint/build/20260418_082009_Demo_20260403_172608_n_good_polynomials/paper.log` -> sin coincidencias

**Plan de Rollback:**
- Trigger: el builder deja de generar el PDF o el saneamiento de metadatos
  degrada el contenido visible del paper.
- Acciones: revertir cambios en `tools/blueprint_paper.py`,
  `blueprint/src/macros/common.tex`, `blueprint/src/macros/print.tex` y
  `tests/test_blueprint_paper.py`.
- Verificacion posterior: `.venv/bin/pytest -q tests/test_blueprint_paper.py` y
  `scripts/build_blueprint_pdf.sh`.

**Comandos Relevantes:**
- `.venv/bin/pytest -q tests/test_blueprint_paper.py` - validar el contrato del builder.
- `scripts/build_blueprint_pdf.sh` - reproducir y verificar el PDF real.
- `git diff -U3` - revisar el alcance del cambio.

**Trazabilidad (links):**
- Issue/Ticket: [N/A]
- PR/Commit: [N/A]
- Decision(es) relacionada(s): [N/A]

**Sincronizacion con PROGRESS.md (si existe):**
- Modo de seguimiento activo: [Estandar]
- Ultimo sync confirmado: [2026-04-18T12:50:11.146+0000]
- Divergencias detectadas: [Ninguna]

**Estado Actual:** [Completado]
**Ultima Actualizacion:** [2026-04-18T14:21:00.530+0000]

---

## [PLAN-20260418-02] [Endurecer flujo de demostraciones Lean y LaTeX]

**Plan ID:** [PLAN-20260418-02] (debe coincidir con el encabezado de la seccion)
**Objetivo General:** Ajustar el proceso de elaboracion de demostraciones para
que exija primero la verificacion Lean a nivel de archivo y despues el build
estricto, y para que incluya una revision argumental del texto LaTeX alineada
con la demostracion Lean antes del flujo final del blueprint.
**Owner:** [Codex]
**Fecha de inicio:** [2026-04-18]
**Estado de aprobacion:** [Aprobado]
**Aprobado por:** [Usuario (chat)]
**Timestamp de aprobacion:** [2026-04-18T15:20:00.000+0000]
**Evidencia de aprobacion (chat/referencia):** [Conversacion actual: mensaje del usuario "Apruebo el plan"]
**Evidencia de /plan:** [Planificacion no interactiva registrada en esta sesion mediante inspeccion del repo + `functions.update_plan`; se intento adicionalmente `codex exec --skip-git-repo-check --json 'Analiza el flujo de elaboración de demostraciones...'` el 2026-04-18, pero el wrapper local fallo al crear el thread por `Read-only file system` y luego por `bwrap: execvp .../vendor/.../codex: No such file or directory`; la evidencia utilizable queda en esta sesion y en este plan.]

**Aplicabilidad de esta skill (no pequena):**
- [x] Cumple al menos 2 criterios de no-pequena (pasos dependientes, impacto multi-modulo/componente critico, validacion no trivial).
- [x] No es tarea trivial de un solo paso.

**Alcance y Entregables:**
- Incluye: actualizar la documentacion operativa del flujo de demostraciones;
  reforzar los skills que coordinan autoria/verificacion (`olympiad-formalize`,
  `lean-prove`, `lean-verify`); ajustar guias globales (`AGENTS.md`,
  `README.md`); revisar si el scaffold LaTeX debe recordar la alineacion
  argumental con Lean; mantener o ampliar tests puntuales del scaffold si el
  texto base cambia.
- Excluye: cambiar la logica del builder PDF; introducir un nuevo comando de
  build; modificar demostraciones Lean existentes; reestructurar el repo;
  alterar artefactos binarios archivados.

**Supuestos:**
- El requisito pedido es de proceso/documentacion y no exige automatizar una
  comprobacion semantica entre Lean y LaTeX mas alla de dejar el paso
  explicitamente en el workflow y en el texto scaffold.
- `scripts/check_lean_json.sh` sigue siendo el comando canonico para la
  verificacion por archivo y `scripts/build_strict.sh` el cierre obligatorio.
- La revision de LaTeX es argumental, breve y unilateral sobre el `.tex`; en
  ese paso no se modifica el `.lean` salvo que un hallazgo posterior abra una
  tarea distinta.

**Dependencias:**
- Skills repo-locales: `.agents/skills/olympiad-formalize/SKILL.md`,
  `.agents/skills/lean-prove/SKILL.md`, `.agents/skills/lean-verify/SKILL.md`.
- Guias globales: `AGENTS.md`, `README.md`.
- Scaffold y tests: `tools/demo_library.py`, `tests/test_demo_library.py`.
- Referencia oficial consultada: OpenAI docs de Codex CLI sobre slash commands
  y uso no interactivo (`/plan`, `codex exec --json`) para contrastar la
  trazabilidad de planificacion.

**Tipo de tarea:** [Mixta]
**Nivel de riesgo/complejidad:** [Bajo]
**Modo de planificacion:** [Simplificado no-pequeno (1 alternativa + 1 descartada)]
**Origen de alternativas:** [Analisis manual en PLANS.md]
**Justificacion del modo elegido:** El cambio toca varias fuentes de verdad del
workflow, pero no introduce arquitectura nueva ni dependencias externas; el
riesgo es bajo y basta un plan corto con una alternativa descartada.
**Modo de seguimiento en `PROGRESS.md`:** [No aplica (sin `PROGRESS.md`)]
**Justificacion del modo de seguimiento:** La trazabilidad en `PLANS.md` es
suficiente para un cambio de proceso/documentacion acotado; no se requiere una
bitacora separada.

**Definicion de Hecho (DoD) - marcar solo criterios aplicables al tipo de tarea:**
- [x] Tipo de tarea declarado y consistente con el alcance.
- [x] (`Codigo` o `Mixta`) Suites relevantes ejecutadas en verde: [`.venv/bin/pytest -q tests/test_demo_library.py`].
- [ ] (`Codigo` o `Mixta`) Si no hay tests aplicables, validacion manual reproducible documentada.
- [x] Revision de cambios cerrada sin hallazgos bloqueantes (`Critico`/`Alto`).
- [x] Hallazgos clasificados con rubrica de severidad cuando la herramienta no reporta severidad explicita.
- [x] Documentacion actualizada en: [`AGENTS.md`, `README.md`, `.agents/skills/olympiad-formalize/SKILL.md`, `.agents/skills/lean-prove/SKILL.md`, `.agents/skills/lean-verify/SKILL.md`, `tools/demo_library.py`, `tests/test_demo_library.py`].
- [x] Criterios de aceptacion funcional cumplidos:
  - [CA-1] El flujo documentado de demostraciones expresa sin ambiguedad:
    `check_lean_json` del demo Lean, luego `build_strict`, y solo despues el
    cierre del flujo formal.
  - [CA-2] El workflow explicita una revision argumental de la seccion LaTeX
    alineada con Lean, dejando claro que ese paso no modifica el archivo Lean.
  - [CA-3] El scaffold o la documentacion inicial recuerdan esa alineacion
    Lean/LaTeX cuando tiene sentido hacerlo.
- [ ] Rollback definido y validado (si aplica).

**Criterios minimos de salida (para estado `Completado`):**
- [x] No hay bloqueantes abiertos (funcionales, seguridad o tests).
- [x] Los checks DoD aplicables estan marcados como cumplidos.
- [x] Existe evidencia verificable de validacion (comandos, logs, diff o commit).

**Riesgos Identificados y Mitigaciones:**
- Riesgo: dejar instrucciones inconsistentes entre skills y documentacion
  global.
  - Mitigacion: actualizar todas las fuentes de verdad encontradas en la
    inspeccion inicial y revisar el diff completo antes de cerrar.
- Riesgo: sobreespecificar el paso LaTeX de forma que parezca una verificacion
  formal automatizada.
  - Mitigacion: redactar el paso explicitamente como revision argumental/manual
    del `.tex`, separada de la verificacion Lean.
- Riesgo: cambiar el scaffold y romper tests por expectativas de texto.
  - Mitigacion: ajustar solo el mensaje minimo necesario y validar con
    `.venv/bin/pytest -q`.

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
- Alternativa A: actualizar de forma coordinada skills, documentacion global y
  scaffold minimo del `.tex`, con tests puntuales si cambian textos base.
  - Score por criterio: [A=5 S=4 R=4 T=5 M=5]
  - Puntaje total ponderado: [91/100]
- Alternativa B: limitar el cambio a `README.md` y `AGENTS.md`, dejando skills y
  scaffold como estan.
  - Score por criterio: [A=2 S=5 R=3 T=2 M=2]
  - Puntaje total ponderado: [56/100]

**Plan Seleccionado (resumen):**
Elegir la alternativa A. El proceso real de elaboracion de demostraciones en
este repo depende de skills repo-locales y del scaffold, no solo del README;
si el cambio queda solo en la documentacion general, Codex seguiria teniendo
instrucciones incompletas durante la ejecucion.

## Pasos del Plan

- [x] STEP-01: Actualizar las fuentes de verdad del workflow para explicitar la
  secuencia Lean correcta.
  - Evidencia/resultado esperado: `AGENTS.md`, `README.md`,
    `.agents/skills/olympiad-formalize/SKILL.md`,
    `.agents/skills/lean-prove/SKILL.md` y
    `.agents/skills/lean-verify/SKILL.md` reflejan primero
    `scripts/check_lean_json.sh <demo.lean>` y luego `scripts/build_strict.sh`.
  - Validacion: revision manual reproducible con `rg -n "check_lean_json|build_strict|LaTeX|argument"` sobre esos archivos.
  - Artefacto esperado: diff coherente del workflow.
- [x] STEP-02: Ajustar el scaffold o texto base del `.tex` para recordar la
  revision argumental alineada con Lean sin tocar Lean en ese paso.
  - Evidencia/resultado esperado: `tools/demo_library.py` deja una instruccion
    consistente con el nuevo workflow.
  - Validacion: inspeccion del template generado y tests del modulo si aplican.
  - Artefacto esperado: diff minimo en `tools/demo_library.py` y
    `tests/test_demo_library.py` si cambia una expectativa.
- [x] STEP-03: Validar el cambio y cerrar la trazabilidad.
  - Evidencia/resultado esperado: tests/documentacion consistentes y plan
    actualizado.
  - Validacion: `.venv/bin/pytest -q` (si aplica) y revision de `git diff -U3`.
  - Artefacto esperado: `PLANS.md` en estado cerrado con evidencia.

**Validacion Manual (solo si no hay tests automatizados):**
- Escenario 1: seguir el flujo documentado de una demo nueva y comprobar que la
  secuencia distingue claramente entre verificacion Lean y revision LaTeX.
- Escenario 2: inspeccionar el scaffold `.tex` y verificar que pide una
  exposicion matematica alineada con Lean, no una modificacion del `.lean`.
- Evidencia capturada en:
  - `rg -n "check_lean_json|build_strict|LaTeX exposition|argumentally consistent|without changing the Lean file" AGENTS.md README.md .agents/skills tools tests -S`
  - `git diff -U3 -- AGENTS.md README.md .agents/skills/olympiad-formalize/SKILL.md .agents/skills/lean-prove/SKILL.md .agents/skills/lean-verify/SKILL.md tools/demo_library.py tests/test_demo_library.py PLANS.md`

**Plan de Rollback:**
- Trigger: las instrucciones nuevas generan contradiccion, ambiguedad operativa
  o fallos de tests.
- Acciones:
  - revertir los cambios en skills/documentacion/scaffold de esta tarea;
  - restaurar las expectativas previas de tests si se tocaron;
  - dejar constancia del motivo en `PLANS.md`.
- Verificacion posterior: confirmar que `rg` vuelve a mostrar el flujo previo y
  que las pruebas/documentacion relevantes quedan estables.

**Comandos Relevantes:**
- `rg -n "check_lean_json|build_strict|LaTeX|argument" AGENTS.md README.md .agents/skills tools tests` - localizar y revisar todos los puntos del flujo.
- `.venv/bin/pytest -q` - validar tests Python si el scaffold cambia.
- `git diff -U3` - revisar la consistencia del cambio antes de cerrar.
- Fallback si faltan herramientas/skills: revision manual del diff y checklist funcional del workflow documentado.

**Trazabilidad (links):**
- Issue/Ticket: [N/A]
- PR/Commit: [N/A]
- Decision(es) relacionada(s): [N/A]

**Sincronizacion con PROGRESS.md (si existe):**
- Modo de seguimiento activo: [No aplica]
- Ultimo sync confirmado: [N/A]
- Divergencias detectadas: [Ninguna]

**Estado Actual:** [Completado]
**Ultima Actualizacion:** [2026-04-18T15:24:00.000+0000]

---
