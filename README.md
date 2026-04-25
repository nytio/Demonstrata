# Biblioteca

<p align="center">
  <img alt="Lean 4" src="https://img.shields.io/badge/Lean-4.29.0-0f5cbd?style=for-the-badge">
  <img alt="mathlib" src="https://img.shields.io/badge/mathlib-v4.29.0-1f8a70?style=for-the-badge">
  <img alt="Python" src="https://img.shields.io/badge/Python-3.12-3776ab?style=for-the-badge">
  <img alt="License: MIT" src="https://img.shields.io/badge/License-MIT-111111?style=for-the-badge">
</p>

<p align="center">
  Un entorno de trabajo para convertir problemas matemáticos en demostraciones
  formales verificadas por Lean 4, documentadas en LaTeX y listas para
  publicar.
</p>

`Biblioteca` combina Lean 4, Mathlib4, automatización en Python y skills locales
de Codex CLI para construir una biblioteca viva de demostraciones. La idea central
es simple: el asistente puede proponer estrategias y borradores, pero la última
palabra siempre la tiene el verificador formal.

## Configuración recomendada de Codex

El repositorio incluye una configuración local en `.codex/config.toml` para usar
`gpt-5.5` con `model_reasoning_effort = "high"`. Esta combinación prioriza una
sola sesión de Codex con razonamiento alto para tareas de demostración formal,
diagnóstico de Lean y planificación multi-paso.

La ejecución multi-agente queda deshabilitada en la configuración del proyecto.
Aunque Codex soporta subagentes en versiones actuales, este repositorio prefiere
un único agente con razonamiento alto para reducir coordinación, consumo extra de
tokens y divergencia entre intentos de prueba.

Con Codex CLI 0.125.0 o posterior, el proyecto aprovecha de forma conservadora
los perfiles de permisos repo-locales y recomienda verificar la configuración
cargada con `/status` o `/debug-config`. Para ejecuciones no interactivas,
`codex exec --json` puede aportar telemetría de tokens de razonamiento, pero no
cambia la política de un solo agente.

## Por qué vale la pena probarlo

- Formaliza resultados en un entorno donde cada prueba se valida
  computacionalmente, no solo por intuición.
- Convierte un problema matemático en tres artefactos coordinados: archivo Lean,
  sección LaTeX y PDF final.
- Mantiene un flujo reproducible con scripts concretos para compilar, depurar y
  publicar resultados.
- Aprovecha `mathlib4` como base de conocimiento matemática sin convertir el
  proyecto en una simple búsqueda de teoremas existentes.
- Deja listo el repositorio para crecer como biblioteca de demostraciones, no
  como una carpeta de experimentos aislados.

## Qué ofrece el proyecto

| Componente | Función |
| --- | --- |
| `Biblioteca/` | Biblioteca Lean del proyecto y espacio de nombres raíz `Biblioteca.*`. |
| `Biblioteca/Demonstrations/` | Demostraciones nuevas en archivos con marca temporal. |
| `blueprint/src/sections/` | Versión en LaTeX de cada demostración. |
| `blueprint/library/pdf/` | PDFs archivados y publicables. |
| `scripts/` | Puntos de entrada reproducibles para compilar, verificar y generar artefactos. |
| `tools/` | Soporte Python para nombres de demos, blueprint y diagnósticos JSON. |
| `.agents/skills/` | Skills locales del repo para estrategia, formalización y verificación. |
| `.github/workflows/` | Automatización de CI de Lean, actualización de dependencias y releases. |

## Lean 4 y su potencial para las demostraciones matemáticas

Lean 4 es un asistente de pruebas y un lenguaje de programación funcional con
un sistema de tipos lo bastante expresivo como para formalizar definiciones,
teoremas y argumentos completos. En la práctica, eso significa que una
demostración no se acepta porque "parece correcta", sino porque el kernel de
Lean puede verificar cada paso.

Ese modelo tiene mucho potencial para las matemáticas:

- ayuda a detectar huecos lógicos que en una prueba informal pueden pasar
  desapercibidos;
- obliga a explicitar hipótesis, cuantificadores y dependencias;
- permite reutilizar resultados ya formalizados en `mathlib4`;
- facilita generar documentos técnicos donde el texto matemático y el código
  Lean están alineados.

En este repositorio, Lean no reemplaza la intuición matemática: la disciplina y
la vuelve verificable. La estrategia puede ser humana o asistida por LLM,
pero el cierre es formal y reproducible.

## Programas que conviene instalar

Para trabajar localmente con el flujo completo del repositorio:

1. `git` para clonar el repo y resolver dependencias de Lake.
2. `python3` y `venv` para la capa de automatización.
3. `elan` para gestionar el toolchain de Lean 4.
4. `lean` y `lake`, instalados a través de `elan`.
5. `latexmk` y `xelatex` para generar los PDFs del blueprint.
6. `node` y `npm` si quieres instalar o actualizar Codex CLI localmente.

Después, dentro del repo:

```bash
.venv/bin/python -m pip install -r requirements.txt
scripts/get_mathlib_cache.sh
scripts/build_strict.sh
```

## Librerías y ecosistema utilizado

### Python

- `pytest`: pruebas de la automatización local.
- `sympy`: apoyo para exploración matemática previa a la formalización.

### Lean y matemáticas formales

- `Lean 4 v4.29.0`: lenguaje y kernel de verificación.
- `mathlib v4.29.0`: biblioteca matemática principal del proyecto.
- `Lake`: gestor de paquetes y compilaciones del ecosistema Lean.

El archivo `lake-manifest.json` también refleja dependencias transitivas del
ecosistema Lean, entre ellas `aesop`, `batteries`, `proofwidgets`,
`LeanSearchClient`, `importGraph`, `Cli`, `quote4`, `Qq` y `plausible`.

## Instalación rápida

```bash
git clone <tu-fork-o-repo> mimate
cd mimate
.venv/bin/python -m pip install -r requirements.txt
scripts/get_mathlib_cache.sh
scripts/build_strict.sh
```

Si no tienes el entorno Python creado todavía, puedes crearlo antes:

```bash
python3 -m venv .venv
.venv/bin/python -m pip install --upgrade pip
.venv/bin/python -m pip install -r requirements.txt
```

## Comandos más útiles

```bash
# Compilación estricta del proyecto Lean
scripts/build_strict.sh

# Diagnósticos JSON de un archivo Lean concreto
scripts/check_lean_json.sh Biblioteca/Demonstrations/Demo_20260402_155130_sum_first_odds.lean

# Resumen legible de diagnósticos JSON
.venv/bin/python scripts/summarize_lean_json.py diagnostics.jsonl

# Crear una demostración nueva
scripts/new_demo.sh "odd numbers sum"
scripts/new_demo.sh --prefix IMO "least norwegian number"

# Validar referencias Lean desde el blueprint
scripts/check_blueprint_decls.sh

# Generar el PDF del trabajo actual
scripts/build_blueprint_pdf.sh

# Ejecutar pruebas Python
.venv/bin/pytest -q

# Persistir el indice local de loogle para evitar esperas en frio
scripts/build_loogle_index.sh

# Consultar Mathlib usando explicitamente el indice persistido canonico
scripts/loogle_local.sh --read-index /home/mario/code/mimate/.local-tools/loogle-indexes/Mathlib.extra --module Mathlib 'Fintype.card_subtype'

# Verificar que el servicio local de loogle responde y devuelve JSON
scripts/check_loogle_local.sh

# Levantar loogle, compilar, correr tests y abrir Codex con una consulta inicial
scripts/init.sh "Tu consulta para Codex"
```

## Ejemplo de uso

Simplemente pedir a Codex CLI un flujo olímpico completo:

```text
/olympiad-formalize resuelve este problema:
Halla todos los enteros positivos $n$ con la siguiente propiedad:
para todo divisor positivo $d$ de $n$, se cumple que $d+1 \mid n$ o bien $d+1$ es primo.
```

Ver solución en: [blueprint/library/pdf/IMO_20260402_213030_divisors_plus_one_divisor_or_prime.pdf](blueprint/library/pdf/IMO_20260402_213030_divisors_plus_one_divisor_or_prime.pdf)

## Cómo funciona el skill `olympiad-formalize`

`olympiad-formalize` es el skill coordinador para problemas de estilo
olimpiada de matemáticas. No se limita a buscar algo en Mathlib, organiza una secuencia
completa para pasar de un enunciado informal a una demostración formal y a un
PDF final.

La dinámica real del skill es la siguiente:

1. Normaliza el problema y lo reformula con precisión matemática.
2. Invoca `mimate-proof-strategy` para comparar 2-3 enfoques de prueba.
3. Elige una ruta estructural de estilo olímpico antes de escribir Lean.
4. Pasa a `lean-prove` para crear la demostración nueva y dividirla en lemas si
   hace falta.
5. Usa `lean-verify` para correr primero `scripts/check_lean_json.sh` sobre el
   demo Lean y, solo si pasa, cerrar la verificación formal con
   `scripts/build_strict.sh`.
6. Cuando Lean acepta el desarrollo, revisa la sección LaTeX emparejada para
   que la exposición argumental coincida con la demostración aceptada en Lean;
   en ese paso no se modifica el archivo Lean.
7. Después activa el flujo del blueprint para producir el PDF final.

El objetivo es privilegiar argumentos matemáticos comprensibles y no una
enumeración ciega de casos o una búsqueda exhaustiva.

## Qué archivos genera `olympiad-formalize`

Cuando el resultado es nuevo para el repositorio, el flujo genera o actualiza
artefactos concretos:

- `Biblioteca/Demonstrations/<Prefijo>_<YYYYMMDD_HHMMSS>_<slug>.lean`
  Archivo Lean nuevo con la demostración formal.
- `blueprint/src/sections/<stem>.tex`
  Sección LaTeX correspondiente a la misma demostración.
- `Biblioteca/Demonstrations.lean`
  Se actualiza para importar la nueva demostración.
- `blueprint/src/content.tex`
  Se actualiza para incluir la nueva sección en el blueprint.
- `blueprint/.current_demo`
  Marca la demostración activa para el generador de PDF.
- `blueprint/build/<timestamp>_<stem>/`
  Directorio temporal de compilación del PDF.
- `blueprint/library/pdf/<stem>.pdf`
  PDF archivado y publicable.

Además, el generador crea dentro de `blueprint/build/` archivos auxiliares como
`paper.tex`, `lean_glossary.tex`, `lean_appendix.tex`, `selected_content.tex` y
el PDF compilado. Esos artefactos temporales no se versionan; el PDF archivado
sí.

## Flujo interno de trabajo

1. Crear una demostración nueva con `scripts/new_demo.sh`.
2. Escribir o refinar el argumento matemático apoyándote en los skills del
   repo.
3. Ejecutar `scripts/check_lean_json.sh <demo.lean>` hasta que el archivo del
   demo quede limpio.
4. Si el chequeo por archivo pasa, ejecutar `scripts/build_strict.sh` para
   cerrar la validación formal completa.
5. Revisar la sección LaTeX emparejada para que la exposición de estilo
   olimpiada sea consistente con la demostración aceptada en Lean; ese paso
   solo ajusta el `.tex`.
6. Comprobar referencias del blueprint con `scripts/check_blueprint_decls.sh`.
7. Generar el PDF con `scripts/build_blueprint_pdf.sh`.
8. Conservar el `.lean`, el `.tex` y el PDF archivado como salida publicable.

## PDF blueprint y artefactos finales

El blueprint usa `amsart` y referencias `\lean{...}` para conectar el texto del
paper con las declaraciones Lean. El resultado final incluye:

- nombres cortos de declaraciones en el cuerpo del texto;
- un glosario Lean construido automáticamente;
- un `Anexo` con el código Lean completo de la demostración seleccionada.

Por defecto, `scripts/build_blueprint_pdf.sh` trabaja sobre la demostración
actual. Si se requier una colección usar:

```bash
scripts/build_blueprint_pdf.sh --demo demo_20260402_155831_cubic_increment_sum --demo IMO_20260403_085959_finite_sets_with_divisibility_b_plus_two_c
scripts/build_blueprint_pdf.sh --all
```

## Exploración avanzada

Para una navegación más profunda de `Mathlib4`, el repo documenta el orden de
uso recomendado y tres capas opcionales en `docs/mathlib-exploration.md`:

- primero, built-ins de Lean como `#check`, `#find`, `exact?`, `apply?`, `rw?`,
  junto con `rg`;
- después, búsqueda local con `loogle` mediante:
  `scripts/build_loogle_local.sh`,
  `scripts/build_loogle_index.sh`,
  `scripts/check_loogle_local.sh`,
  `scripts/loogle_local.sh`,
  `scripts/start_loogle_local_server.sh`;
- luego, exportación NDJSON con `lean4export`;
- y por último, exploración semántica con LeanExplore.

Para un clon limpio, `scripts/build_loogle_local.sh` asume que ya existe el
source upstream de `loogle` en `.local-tools/loogle`. La búsqueda sobre
`Biblioteca` sigue siendo por módulo (`--module`), no como agregado global.
Para `Mathlib`, la ruta canónica del índice persistido en este workspace es
`/home/mario/code/mimate/.local-tools/loogle-indexes/Mathlib.extra` y se
reutiliza con `--read-index`; solo se regenera cuando cambia `Mathlib`.

No son requisitos de la puesta en marcha base. Son aceleradores opcionales
cuando la exploración de resultados en `mathlib` se vuelve un cuello de botella
real.

## Licencia

Este proyecto se distribuye bajo licencia MIT. Consulta [LICENSE](LICENSE).
