# DECISIONS

## [DEC-20260402-01] [2026-04-02] [Mantener reglas, skills y automatizacion dentro del repo]

**Estado:** [Aprobada]
**Owner:** [Codex]
**Fecha efectiva:** [2026-04-02]
**Proxima fecha de revision:** [N/A]
**Estado de implementacion:** [Completa]
**Reemplaza:** [Ninguna]
**Reemplazada por:** [N/A]

**Contexto:**
El workspace debia quedar reutilizable desde esta misma carpeta, incluyendo
reglas para Codex, scripts de verificacion y skills mencionadas en
`instrucciones.md`.

**Decision:**
Mantener toda la automatizacion operativa dentro del repo en lugar de depender
de configuracion global:
- `AGENTS.md`
- `.codex/`
- `.agents/skills/`
- `scripts/`
- `tools/`

**Drivers de decision:**
- Driver 1: reproducibilidad del entorno por carpeta.
- Driver 2: trazabilidad local de comandos, reglas y skills.
- Driver 3: menor dependencia de configuracion oculta fuera del repo.

**Componentes afectados:**
- `AGENTS.md`
- `.codex/config.toml`
- `.codex/rules/default.rules`
- `.agents/skills/lean-verify/SKILL.md`
- `.agents/skills/lean-prove/SKILL.md`
- `scripts/`
- `tools/`

**Alternativas consideradas:**
- Opcion A: mover reglas y skills a `~/.codex` y `~/.agents`.
- Opcion B: dejar solo el proyecto Lean y documentar el resto manualmente.

**Impacto:**
- Tecnico: cualquier sesion abierta en el repo ve el mismo contrato operativo.
- Riesgos: el proyecto debe estar marcado como trusted para que Codex cargue `.codex/config.toml`.
- Seguimiento: revisar en futuras sesiones si conviene empaquetar las skills como plugin.
- Criterios de reversion: mover configuracion a nivel usuario solo si el repo deja de ser el boundary correcto.
- Efecto esperado en pruebas/operacion: menor variabilidad y validacion mas repetible.

**Referencias:**
- Plan: `PLANS.md` ([PLAN-20260402-01 / STEP-03 y STEP-04])
- Commit/PR: [N/A]
- Issue/Ticket: [N/A]

---

## [DEC-20260424-01] [2026-04-25] [Usar gpt-5.5 con un solo agente de alto razonamiento]

**Estado:** [Aprobada]
**Owner:** [Codex]
**Fecha efectiva:** [2026-04-25]
**Proxima fecha de revision:** [N/A]
**Estado de implementacion:** [Completa]
**Reemplaza:** [Ninguna]
**Reemplazada por:** [N/A]

**Contexto:**
El repositorio usa Codex para formalizacion Lean, depuracion de pruebas y
automatizacion local. La solicitud actual requiere adaptar la configuracion y la
documentacion para `gpt-5.5`, revisar capacidades actuales de Codex y conservar
la restriccion operativa de no usar multiples agentes. La version local
verificada es `codex-cli 0.125.0`.

**Decision:**
Configurar Codex repo-localmente con `model = "gpt-5.5"` y
`model_reasoning_effort = "high"`, manteniendo `features.multi_agent = false`.
La politica preferida es una sola sesion de agente con razonamiento alto, no
subagentes ni ejecucion multi-agente. De Codex CLI 0.125.0 se aprovechan solo
cambios compatibles con esa politica: perfiles de permisos repo-locales,
verificacion con `/status` o `/debug-config`, y telemetria de razonamiento en
`codex exec --json` cuando se use planificacion no interactiva.

**Drivers de decision:**
- Driver 1: las demostraciones Lean requieren diagnostico y planificacion
  profundos mas que paralelismo especulativo.
- Driver 2: los subagentes consumen tokens adicionales y agregan coordinacion,
  lo que no encaja con la restriccion aprobada para este repositorio.

**Componentes afectados:**
- `.codex/config.toml`
- `AGENTS.md`
- `README.md`
- `PLANS.md`

**Alternativas consideradas:**
- Opcion A: `gpt-5.5` con `model_reasoning_effort = "high"` y multi-agente
  deshabilitado.
- Opcion B: habilitar subagentes y limitar concurrencia a un hilo.
- Opcion C: actualizar solo la documentacion sin fijar configuracion repo-local.

**Impacto:**
- Tecnico: Codex inicia con el modelo y esfuerzo esperados cuando el proyecto
  esta marcado como trusted.
- Riesgos: si OpenAI cambia la disponibilidad del modelo o las claves de
  configuracion, habra que revisar la documentacion oficial y ajustar el repo.
- Seguimiento: verificar con `/status` o `/debug-config` en Codex CLI cuando se
  abra una nueva sesion.
- Criterios de reversion: volver a la configuracion anterior o elegir otro
  modelo si `gpt-5.5` no esta disponible para la cuenta o superficie usada.
- Efecto esperado en pruebas/operacion: sin impacto en Lean/Python; afecta solo
  defaults operativos de Codex y documentacion.

**Referencias:**
- Plan: `PLANS.md` ([PLAN-20260424-01 / STEP-02])
- Commit/PR: [N/A]
- Issue/Ticket: [N/A]
