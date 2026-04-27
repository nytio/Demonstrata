# Exploracion Profunda de Mathlib

Este proyecto usa `Mathlib` como base principal para demostraciones formales.
La verificacion sigue dependiendo de Lean, pero para exploracion mas profunda
conviene distinguir tres capas adicionales:

1. busqueda local con `loogle`;
2. exportacion estructurada a NDJSON;
3. busqueda semantica sobre un indice ya construido.

La incorporacion recomendada es escalonada: usar primero las primitives de Lean
y del repo, despues `loogle` local, luego NDJSON como flujo opcional, y dejar
el indice semantico como capa avanzada, no como requisito del bootstrap base.

Estas herramientas de exploracion no cambian el objetivo central del repo:
servir como soporte para que el LLM escriba demostraciones nuevas en
`Biblioteca/Demonstrations/`. Buscar o indexar declaraciones no sustituye la
sintesis de una prueba nueva cuando el usuario pide formalizar un resultado.

## 1. Exportacion NDJSON con `lean4export`

### Lo que dicen las fuentes

- El repositorio oficial define `lean4export` como un exportador de
  declaraciones de Lean 4 usando el formato NDJSON.
- La documentacion oficial de uso indica compilar el binario con `lake build`
  y ejecutarlo dentro del entorno de Lake.
- La pagina de Reservoir confirma el flujo de ejecucion y la compatibilidad
  por versiones de Lean.
- El formato de salida esta documentado aparte, lo que lo vuelve apropiado
  para pipelines reproducibles y herramientas offline.

Fuentes primarias:

- `lean4export` README:
  https://github.com/leanprover/lean4export
- Paquete Reservoir:
  https://reservoir.lean-lang.org/%40leanprover/lean4export
- Especificacion del formato:
  https://ammkrn.github.io/type_checking_in_lean4/export_format.html

### Flujo minimo extraido de la documentacion

```bash
lake build
lake env <path-to-lean4export> Mathlib > out.ndjson
```

Ejemplo documentado por el propio proyecto:

```bash
lake env ../.lake/build/bin/lean4export Mathlib > out.ndjson
```

Tambien soporta:

- exportar varios modulos en una sola invocacion;
- filtrar declaraciones tras `--`;
- incluir `unsafe` con `--export-unsafe`;
- preservar `Expr.mdata` con `--export-mdata`.

### Evaluacion para este repo

Pertinencia: alta.

Si aporta porque:

- no sustituye a Lean ni altera el criterio de verdad del proyecto;
- produce una representacion portable y bien documentada de `Mathlib`;
- encaja con futuros indexadores, analisis offline o recuperacion estructurada
  para agentes.

No conviene aun como dependencia obligatoria porque:

- agrega otra herramienta y binario al entorno;
- el flujo base de prueba y verificacion ya funciona sin ello;
- solo se amortiza cuando hay exploracion recurrente a escala de `Mathlib`.

Decision recomendada:

- dejarlo documentado como opcion intermedia y pertinente;
- no instalarlo por defecto en el bootstrap actual;
- activarlo cuando la navegacion con `rg`, imports y diagnosticos ya no baste.

## 2. Indices semanticos con LeanExplore

### Lo que dicen las fuentes

- El paper de LeanExplore presenta busqueda semantica sobre declaraciones Lean
  usando una estrategia hibrida con embeddings, recuperacion lexical y ranking.
- El abstract de arXiv indica soporte para `Mathlib`, descarga de la base de
  datos, self-hosting e integracion con MCP.
- El repositorio documenta dos modos: paquete liviano contra API remota y
  backend local con dependencias ML, descarga de datos y servidor MCP local.

Fuentes primarias:

- Paper/arXiv:
  https://arxiv.org/abs/2506.11085
- Repositorio:
  https://github.com/justincasher/lean-explore

### Flujo minimo extraido de la documentacion

Uso remoto ligero:

```bash
.venv/bin/python -m pip install lean-explore
```

Uso local con indice y MCP:

```bash
.venv/bin/python -m pip install 'lean-explore[local]'
.venv/bin/lean-explore data fetch
.venv/bin/lean-explore mcp serve --backend local
```

### Evaluacion para este repo

Pertinencia: media-alta, pero como capacidad avanzada.

Si aporta porque:

- permite descubrir declaraciones por significado y no solo por nombre;
- sirve especialmente cuando el LLM necesita recuperar resultados cercanos pero
  no conoce el identificador exacto en `Mathlib`;
- ya contempla integracion con agentes via MCP.

No conviene como parte del bootstrap base porque:

- introduce dependencias y datos bastante mas pesados que el flujo actual;
- la necesidad todavia no es universal en este repo;
- es una capa de exploracion, no una necesidad de verificacion.

Decision recomendada:

- mencionarlo explicitamente en documentacion y skills;
- no instalarlo ni configurarlo por defecto en este proyecto;
- evaluarlo para adopcion local solo si la exploracion semantica de `Mathlib`
  se vuelve una necesidad recurrente.

## Recomendacion operativa

Mantener cuatro niveles de exploracion, en este orden:

1. Basico dentro de Lean y del repo:
   `#check`, `#find`, `exact?`, `apply?`, `rw?`, `rg`, imports acotados,
   `scripts/check_lean_json.sh` y docs de `Mathlib`.
2. Busqueda local por nombre o forma del enunciado:
   `scripts/check_loogle_local.sh`, `scripts/loogle_local.sh`, y solo si hace
   falta repeticion dentro de Lean, `scripts/start_loogle_local_server.sh`.
3. Inspeccion estructurada offline:
   exportacion NDJSON con `lean4export`.
4. Recuperacion semantica:
   indice remoto o local tipo LeanExplore.

## 3. Loogle local para este repo

Para este proyecto, `loogle` es la mejor capa local para busqueda por nombre,
subexpresion y forma del enunciado cuando ya existe un identificador o patron
Lean razonablemente cercano.

El repo queda preparado con estos entrypoints:

```bash
scripts/build_loogle_local.sh
scripts/build_loogle_index.sh
scripts/check_loogle_local.sh
scripts/loogle_local.sh --json 'Nat.gcd_eq_left'
scripts/start_loogle_local_server.sh
```

### Bootstrap minimo

Antes del primer build, el script asume que existe el source upstream de
`loogle` en `.local-tools/loogle`:

```bash
git clone https://github.com/nomeata/loogle .local-tools/loogle
scripts/build_loogle_local.sh
```

Si ese directorio no existe, `scripts/build_loogle_local.sh` falla de forma
intencional con un mensaje de bootstrap.

### Uso sobre `Mathlib`

El wrapper usa `Mathlib` por defecto:

```bash
scripts/loogle_local.sh 'Nat.gcd_eq_left'
```

Si ya existe un indice persistido para `Mathlib`, el wrapper lo reutiliza
automaticamente con `--read-index` desde:

```text
/home/mario/code/mimate/.local-tools/loogle-indexes/Mathlib.extra
```

Para construirlo explicitamente:

```bash
scripts/build_loogle_index.sh
```

La forma recomendada para forzar ese indice precalculado en este repo es:

```bash
scripts/loogle_local.sh \
  --read-index /home/mario/code/mimate/.local-tools/loogle-indexes/Mathlib.extra \
  --module Mathlib \
  'Fintype.card_subtype'
```

Esto coincide con la documentacion primaria de `loogle`: el CLI soporta
`--read-index file`, pero el caller debe garantizar que el indice corresponde
al modulo y al search path correctos.

### Uso sobre `Biblioteca`

Para consultar declaraciones propias, conviene fijar el modulo actual o uno de
los modulos ya construidos:

```bash
scripts/loogle_local.sh \
  --module Biblioteca.Demonstrations.Demo_20260402_180809_weighted_binomial_sum \
  'Biblioteca.Demonstrations.weighted_binomial_sum'
```

Si ese modulo se consulta con frecuencia, tambien se puede persistir su indice:

```bash
scripts/build_loogle_index.sh \
  --module Biblioteca.Demonstrations.Demo_20260402_180809_weighted_binomial_sum
```

El archivo se guarda por defecto en:

```text
.local-tools/loogle-indexes/Biblioteca__Demonstrations__Demo_20260402_180809_weighted_binomial_sum.extra
```

Esto es intencional: el agregado `Biblioteca` no es hoy una base estable para
`loogle`, porque el workspace tiene una demostracion rota sin `.olean`
correspondiente y ademas hay modulos que no pueden importarse todos juntos por
redefinir algunos nombres.

En otras palabras:

- para `Mathlib`, el wrapper por defecto ya sirve;
- para `Biblioteca`, hoy la forma estable es consultar por modulo;
- no conviene prometer aun una busqueda global sobre todo `Biblioteca`.

### Fallback operativo cuando `loogle` tarda demasiado

Si una sesion de Codex informa que el binario CLI de `loogle` existe pero se
queda colgado al construir o cargar el indice, la ruta correcta en este repo
es:

1. buscar si ya existe un indice persistido en `.local-tools/loogle-indexes/`;
2. para `Mathlib`, reintentar explicitamente con:

   ```bash
   scripts/loogle_local.sh \
     --read-index /home/mario/code/mimate/.local-tools/loogle-indexes/Mathlib.extra \
     --module Mathlib \
     '<query>'
   ```

3. si hace falta depurar manualmente, pasar `--read-index <archivo.extra>`
   de forma explicita;
4. si no existe indice persistido, no esperar indefinidamente: seguir con
   `rg`, `#check`, `#find`, `exact?`, `apply?`, `rw?` y las declaraciones ya
   localizadas.

El objetivo del fallback no es forzar siempre la reconstruccion del indice,
sino aprovechar indices repo-locales ya preparados cuando existan.

### Gate operativo antes de usar `loogle`

Cuando una skill decida usar `loogle`, primero debe ejecutar:

```bash
scripts/check_loogle_local.sh --start
```

Este comando es el preflight operativo del repo. Si el servidor local ya esta
corriendo, lo verifica; si no esta corriendo, lo arranca en segundo plano y
comprueba una consulta JSON real. Si el indice persistido de Mathlib ya existe,
el servidor lo reutiliza. Este gate no significa regenerar el indice.

La ruta canonica del indice persistido de Mathlib es:

```text
/home/mario/code/mimate/.local-tools/loogle-indexes/Mathlib.extra
```

Por tanto, para busquedas CLI sensibles a sandbox, la forma explicita sigue
siendo:

```bash
scripts/loogle_local.sh \
  --read-index /home/mario/code/mimate/.local-tools/loogle-indexes/Mathlib.extra \
  --module Mathlib \
  '<query>'
```

Si el flujo dice "usar Loogle", debe haber evidencia de dos cosas: el preflight
del servidor local y al menos una consulta dirigida a la forma del lema que falta.

### Servidor local compatible con `LeanSearchClient`

El servidor JSON queda en `http://127.0.0.1:8088/json` por defecto. Para hacer
que `#loogle` use la instancia local, exportar:

```bash
export LEANSEARCHCLIENT_LOOGLE_API_URL=http://127.0.0.1:8088/json
```

Luego levantar el servidor:

```bash
scripts/start_loogle_local_server.sh
```

Y verificar que realmente quedo usable antes de depender de `#loogle`:

```bash
scripts/check_loogle_local.sh
```

### Inicio manual del servicio

Forma recomendada, en primer plano:

```bash
cd /home/mario/code/mimate
./scripts/start_loogle_local_server.sh
```

En otra terminal, verificar:

```bash
cd /home/mario/code/mimate
./scripts/check_loogle_local.sh
```

Si se quiere dejar en segundo plano:

```bash
cd /home/mario/code/mimate
nohup ./scripts/start_loogle_local_server.sh >/tmp/mimate-loogle-local.log 2>&1 &
./scripts/check_loogle_local.sh
```

Si no se esta dentro de una sesion de Codex que lea `.codex/config.toml`,
exportar la URL manualmente antes de usar `#loogle` desde Lean:

```bash
export LEANSEARCHCLIENT_LOOGLE_API_URL=http://127.0.0.1:8088/json
```

Para detener el servicio:

```bash
pkill -f 'tools/loogle_local_server.py'
```

Para reiniciarlo de forma limpia:

```bash
cd /home/mario/code/mimate
./scripts/restart_loogle_local.sh
```

Si se quiere reiniciar en segundo plano y dejarlo verificado:

```bash
cd /home/mario/code/mimate
./scripts/restart_loogle_local.sh --background
```

El proyecto tambien deja configurado en `.codex/config.toml`:

```toml
[shell_environment_policy.set]
LEANSEARCHCLIENT_LOOGLE_API_URL = "http://localhost:8088/json"
```

Eso hace que los subprocesses de Codex apunten a la instancia local cuando el
servidor esta corriendo y el proyecto se carga como trusted. La configuracion
no arranca el servidor por si sola; solo inyecta la URL.

Notas practicas:

- la primera consulta puede tardar porque `loogle` construye su indice en el
  arranque;
- para evitar esa espera en sesiones repetidas, conviene correr antes
  `scripts/build_loogle_index.sh`;
- para `Mathlib`, el repo trata
  `/home/mario/code/mimate/.local-tools/loogle-indexes/Mathlib.extra`
  como la ruta canonica del indice persistido;
- el servidor deja ese indice caliente y por eso conviene mas que invocar el
  binario desde cero en cada consulta repetida;
- si cambian los `.olean` del repo o se agregan demostraciones nuevas, volver a
  correr `scripts/build_loogle_local.sh` y, si se usa indice persistido,
  regenerarlo con `scripts/build_loogle_index.sh --force`.
- el indice persistido de `Mathlib` no se regenera por cambios en
  `Biblioteca/Demonstrations/`; solo cuando cambia la libreria `Mathlib`.
- cuando `scripts/check_loogle_local.sh` falle, corregir primero el bootstrap,
  el build o el servidor local antes de culpar a `#loogle`.

## Herramientas Python utiles para estas rutas

Los skills de este repo ya pueden apoyarse en herramientas Python existentes:

- `.venv/bin/python` para scripts auxiliares y validacion reproducible;
- `tools/loogle_local_server.py` como wrapper stdlib para exponer `loogle` por
  `http://127.0.0.1:8088/json`;
- `.venv/bin/lean-explore` para la escalacion semantica, sin asumir GPU.

## Criterio de incorporacion

Adoptar solo si resuelve un problema real del repo:

- usar NDJSON cuando haga falta construir exploracion offline, indexado propio
  o pasar estructura formal a otra herramienta;
- usar indice semantico cuando el cuello de botella sea descubrir declaraciones
  de `Mathlib` por concepto y no por nombre.

Mientras ese problema no sea recurrente, la recomendacion sigue siendo
documentar estas rutas y mantenerlas fuera del bootstrap obligatorio.
