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
