# Exploracion Profunda de Mathlib

Este proyecto usa `Mathlib` como base principal para demostraciones formales.
La verificacion sigue dependiendo de Lean, pero para exploracion mas profunda
declarativa conviene distinguir dos extras distintos:

1. exportacion estructurada a NDJSON;
2. busqueda semantica sobre un indice ya construido.

La incorporacion recomendada es escalonada: documentar ambas rutas, adoptar
primero NDJSON como flujo opcional y dejar el indice semantico como capa
avanzada, no como requisito del bootstrap base.

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
pip install lean-explore
```

Uso local con indice y MCP:

```bash
pip install 'lean-explore[local]'
lean-explore data fetch
lean-explore mcp serve --backend local
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

Mantener tres niveles de exploracion:

1. Basico:
   `rg`, imports acotados, `scripts/check_lean_json.sh`, docs de `Mathlib`.
2. Intermedio:
   exportacion NDJSON con `lean4export` para inspeccion estructurada offline.
3. Avanzado:
   indice semantico remoto o local tipo LeanExplore para recuperacion por
   significado y uso por agentes.

## Criterio de incorporacion

Adoptar solo si resuelve un problema real del repo:

- usar NDJSON cuando haga falta construir exploracion offline, indexado propio
  o pasar estructura formal a otra herramienta;
- usar indice semantico cuando el cuello de botella sea descubrir declaraciones
  de `Mathlib` por concepto y no por nombre.

Mientras ese problema no sea recurrente, la recomendacion sigue siendo
documentar ambas rutas y mantenerlas fuera del bootstrap obligatorio.
