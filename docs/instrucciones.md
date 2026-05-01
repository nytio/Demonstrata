# Demonstrata: demostraciones formales en Lean con Codex CLI en Ubuntu

## Objetivo y arquitectura de verificación

Demonstrata separa claramente dos roles: **un LLM (Codex) redacta la demostración en el lenguaje formal de Lean** y **Lean (el kernel/verificador) decide si esa demostración es válida** al compilar el archivo. En la práctica, el criterio operativo es: *la prueba es aceptable cuando el proyecto compila sin errores* (y conviene endurecerlo para que también “falle” con advertencias, por ejemplo cuando aparece `sorry`).

El valor añadido del LLM no es “calcular” sino **inventar la estrategia de prueba** y traducirla a construcciones compatibles con la biblioteca formal disponible. En teoría de números, esa biblioteca base casi siempre es **mathlib** (la biblioteca comunitaria de Lean), porque ya contiene definiciones, lemas, infraestructura algebraica y tácticas que reducen drásticamente el trabajo de formalización.

**Python 3.12** entra únicamente como “pegamento”: scripts para ejecutar `lake`/`lean`, resumir errores e iterar automáticamente. Esto encaja bien con tu requisito: *no demostrar en Python*, sino usar Python como automatización alrededor del verificador.

## Instalación de herramientas en Ubuntu

### Codex CLI

Según la documentación oficial, Codex CLI se instala con `npm` y se ejecuta con `codex`; en el primer uso te pide autenticarte.
Para fijarte en la versión solicitada, el changelog de Codex indica explícitamente cómo instalar **Codex CLI 0.118.0** con `npm install -g @openai/codex@0.118.0`.

Codex CLI es de entity["company","OpenAI","ai research company"] y está publicado como software open-source.

### Lean mediante elan

La vía estándar en Linux para manejar Lean es **elan**, un gestor de toolchains que coloca `lean` y `lake` en tu `PATH` y selecciona automáticamente la versión indicada por el archivo `lean-toolchain` del proyecto. La instalación típica en Linux/macOS es ejecutar el instalador `elan-init.sh` (con `curl … | sh`).

Un punto importante para Demonstrata y otros proyectos con dependencias: `lake` descarga dependencias vía Git, así que **`git` es un prerrequisito real** cuando trabajas con Lake.

## Configuración de Lean y mathlib para teoría de números

### Crear un proyecto dependiente de mathlib

La guía oficial de mathlib para downstream projects recomienda crear proyectos nuevos con:

- `lake +leanprover-community/mathlib4:lean-toolchain new <your_project_name> math`

y señala que esto configura un proyecto Lake con la dependencia de mathlib.

Para evitar compilar miles de módulos desde cero, la misma guía recomienda ejecutar `lake exe cache get` para traer *build artifacts* precompilados (cached `olean`s). Esto hace que `import Mathlib` o imports más específicos sean mucho más rápidos.

### “Biblioteca de conocimiento”: qué se descarga realmente

En este stack, la “base de conocimiento” práctica es:

- **mathlib como dependencia** del proyecto (descargada por Lake).
- **cache compilada** de mathlib via `lake exe cache get`.

Opcionalmente, puedes descargar/construir recursos extra para navegación/descubrimiento:

- **Docs HTML locales**: el README de mathlib describe cómo construir documentación HTML clonado `mathlib4_docs`, ejecutando `lake exe cache get` y luego `lake build Mathlib:docs`, con resultado en `.lake/build/doc`.
- **Exportación de declaraciones** para indexado/búsqueda: `lean4export` exporta módulos (p. ej. `Mathlib`) a NDJSON, con un formato documentado (`out.ndjson`/`export format`).
- **Índices semánticos**: trabajos como *LeanExplore* describen una base descargable para búsqueda semántica sobre paquetes Lean (incluyendo Mathlib) y mencionan que su base se puede descargar y self-hostear, además de integrarse con agentes.

### Sugerencias concretas para teoría de números dentro de mathlib

mathlib tiene un árbol amplio bajo `Mathlib.NumberTheory.*` (p. ej. módulos para símbolos de Legendre/Jacobi, L-series, padics, etc.). Esto importa porque muchas formalizaciones “de teoría de números” requieren infraestructura que ya existe allí, y el LLM puede apoyarse en esos módulos para no reinventar.

Como ejemplos representativos (no exhaustivos):

- Aritmética modular: `Mathlib.Data.ZMod.Basic`.
- Símbolo de Legendre y extensiones: `Mathlib.NumberTheory.LegendreSymbol.Basic`.

## Automatización de verificación y parseo de errores

### Verificación fuerte del proyecto

Conviene que el verificador sea el árbitro final y además que **no acepte “pruebas con `sorry`”**. Lake introdujo la opción `--wfail` para que el build falle si hay warnings; como `sorry` suele producir advertencias, esto hace que “compilar con `sorry`” se convierta en fallo duro en CI/automatización.

### Verificación de archivo y salida estructurada

Para el bucle “edita → compila → corrige”, también es útil compilar **solo el archivo** que estás trabajando:

- Lean 4.8 añadió `lake lean <file> …`, documentándolo como equivalente a `lake env lean <file> …` pero *construyendo imports previamente*, lo que encaja muy bien con verificación incremental.

Para automatizar diagnósticos, Lean agregó el flag de CLI `--json` para emitir mensajes como JSON.  
Además, es un patrón real en investigación/automatización compilar con `lake env lean --json` en entornos fijados a Mathlib, usando el exit code para decidir éxito y tratando `sorry` como fallo.

Esto habilita tu parte “Python de apoyo”: leer stdout JSON, extraer severidades/mensajes y alimentar la siguiente iteración del LLM con un resumen limpio.

Si quisieras interacción más rica desde Python (REPL/step-by-step), existen paquetes como `lean-interact`, diseñado para interactuar con Lean mediante un REPL. Es opcional; tu diseño puede funcionar sin ello, solo con `subprocess` + `--json`.

## Integración con Codex CLI en modo interactivo y scripting

### Capas de configuración y documentos de instrucciones

Codex maneja configuración por capas:

- Config personal: `~/.codex/config.toml`.
- Overrides de proyecto: `.codex/config.toml`, cargados en cascada desde el root del repo hacia el directorio actual (y **solo si el proyecto es “trusted”**).
- Estado local por defecto bajo `CODEX_HOME` (default `~/.codex`).

Para “programar” la conducta de Codex en este caso de uso, el mecanismo más directo es **AGENTS.md**: Codex lee `AGENTS.md` automáticamente desde el home de Codex y desde el árbol del repo, con soporte para variantes como `AGENTS.override.md`, etc.

En la práctica, AGENTS.md es donde debes imponer reglas como:

- “Prohibido dejar `sorry`”.
- “Siempre ejecutar verificación tras cambios”.
- “Preferir pruebas estructuradas (lemas auxiliares)”.

### Reglas para control de comandos

Codex ofrece “Rules” (experimentales) para controlar qué comandos puede ejecutar fuera del sandbox, con reglas de prefijo (`prefix_rule`) que deciden `allow`/`prompt`/`forbidden`, y una herramienta `codex execpolicy check` para probar cómo aplican las reglas.

Esto sirve para tu caso porque puedes permitir sin fricción comandos “seguros” como `lake build`/`lake lean` y forzar confirmación para `bash -lc` genéricos o acciones destructivas.

### `codex exec` para bucles automatizados

El modo no interactivo (`codex exec`) está documentado como la forma de automatizar flujos repetibles. Puede emitir:

- Un stream de eventos en JSONL con `--json`.
- El último mensaje a stdout o a un archivo con `--output-last-message`.

También hay restricciones prácticas: por defecto, `codex exec` exige estar dentro de un repositorio Git; existe un flag `--skip-git-repo-check` para saltarlo, pero para tu caso (proyectos Lean) lo natural es mantener todo en Git.

Para la versión que te interesa, el changelog oficial de Codex CLI 0.118.0 indica una mejora directamente útil: **`codex exec` soporta el flujo “prompt + stdin”**, permitiendo tuberías donde pasas errores por stdin y el prompt por argumento, lo cual encaja perfecto con “compilo → recojo errores → los paso a Codex”.

### Skills para estandarizar rutinas

Para convertir tu proceso en “playbooks” repetibles, Codex soporta skills; la documentación define rutas repo-locales bajo `.agents/skills` y explica que Codex escanea esas carpetas desde el directorio actual hacia el root del repo, además de ubicaciones de usuario y admin.

En este caso de uso, dos skills típicos son:

- `lean-verify`: ejecutar verificación estricta y reportar errores completos.
- `lean-prove`: transformar un enunciado en un `theorem … := by` y llevarlo hasta compilación.

## Entregable y estructura de directorios

El archivo entregable (sin referencias) está listo para usarse como **instrucciones operativas para Codex** e incluye:

- Estructura de repo recomendada (`.codex/`, `.agents/skills/`, `scripts/`, árbol Lean).
- Plantilla de `AGENTS.md`.
- Scripts de verificación (`lake build --wfail`), chequeo por archivo (`lake lean … -- --json`), y un script Python para resumir mensajes JSON.
- Ejemplo de reglas (`.codex/rules/default.rules`) y skills (`SKILL.md`).
- Opcionales para documentación offline e indexado (mathlib docs, exportación NDJSON).
