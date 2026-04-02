from __future__ import annotations

from io import StringIO

from tools.lean_json_summary import load_diagnostics, render_summary


def test_load_diagnostics_skips_non_diagnostic_lines() -> None:
    raw = '\n'.join(
        [
            '{"severity":"warning","message":"unused variable","fileName":"A.lean","pos":{"line":3,"column":5}}',
            '{"kind":"progress","text":"ignored"}',
        ]
    )

    diagnostics = load_diagnostics(StringIO(raw))

    assert len(diagnostics) == 1
    assert diagnostics[0].severity == "warning"
    assert diagnostics[0].location() == "A.lean:3:5"


def test_render_summary_reports_counts_and_locations() -> None:
    raw = '\n'.join(
        [
            '{"severity":"error","message":"type mismatch","fileName":"B.lean","pos":{"line":7,"column":11}}',
            '{"severity":"warning","message":"declaration uses sorry","fileName":"B.lean","pos":{"line":9,"column":1}}',
        ]
    )

    diagnostics = load_diagnostics(StringIO(raw))
    summary = render_summary(diagnostics, max_items=10)

    assert "errors=1 warnings=1 info=0" in summary
    assert "[error] B.lean:7:11 type mismatch" in summary
    assert "[warning] B.lean:9:1 declaration uses sorry" in summary
