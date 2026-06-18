---
description: Critique a dvt dashboard before you apply it — runs a narrative + layout review (a fresh, unbiased pass) and folds in the engine's deterministic lints, then gives you a GO / REVISE recommendation with concrete fixes.
---

# /dvt:dvt-review — critique a dashboard before applying it

You are running a **pre-apply design critique** of a dvt dashboard. The point is a *clean read*: the
session that just authored a spec carries the same assumptions that produced it and is the worst judge
of it, so this command dispatches two **fresh subagents** to critique it from scratch, folds in the
engine's deterministic checks, and hands the user one verdict with fixes — **before**
`dvt_dashboard_apply_spec` persists anything.

> Why this lives in dvt: a viz-quality audit (narrative spine + layout craft, grounded in Gestalt /
> Tufte / Minto) is dvt's own domain expertise, shipped as a first-class feature — not a generic
> starter rubric (ADR-0018). It composes with, and never duplicates, the engine's deterministic lints.

## Step 1 — resolve the spec under review

Figure out what to review, in this order:

1. **An argument was given** — `$ARGUMENTS`:
   - a dashboard id (a UUID, or `dvt://…`) → fetch it: `dvt_dashboard_get(dashboard_id, format="full")`
     and review the returned `spec`.
   - a path to a `.json` file → read it.
   - pasted spec JSON → use it directly.
2. **No argument** — review the dvt dashboard spec **just authored in this session** (the one the user
   is about to apply). If you can't tell which spec that is, ask.

If nothing resolves to a spec, ask the user for a dashboard id or spec and stop.

## Step 2 — run the deterministic lint

Call `dvt_spec_validate(spec)`. Keep the `warnings[]` it returns — each is `category`-tagged
(`collision`, `contrast:token-pair`, `contrast:coverage`, `layout`, `echarts-key`, `data-binding`).
These are the cheap, exact checks; the subagents must **fold them in, not recompute them**. If the spec
fails hard schema validation (`valid: false`), report the field errors and stop — there's nothing to
critique until it's a valid spec.

## Step 3 — dispatch both critics (fresh, in parallel)

Dispatch BOTH subagents in one step so they run concurrently, each with the spec JSON and the lint
`warnings[]` from Step 2:

- **`dvt-narrative-critic`** — does it tell a coherent analytical story? (answer-first, structure,
  cross-page spine, key message)
- **`dvt-layout-critic`** — is the layout/visual craft sound? (grouping, focal hierarchy, chart-type
  fit, data-ink, titles) — folding in the deterministic findings.

They are read-only and never edit or apply the spec.

## Step 4 — synthesize one verdict

Merge both critiques + the deterministic lint into a single report. Lead with a clear recommendation:

- **GO** — coherent narrative, sound layout, no HIGH findings. Safe to apply.
- **REVISE FIRST** — any HIGH layout finding, an INCOHERENT narrative verdict, or a `collision` /
  `data-binding` / below-AA `contrast:token-pair` lint hit. List the minimal fixes to reach GO.
- **GO WITH NOTES** — only MEDIUM/LOW findings; apply if the user accepts them.

Present:

```markdown
## dvt review: [dashboard title]

**Recommendation:** GO / REVISE FIRST / GO WITH NOTES — [one-line reason]

### Must-fix before applying
- [finding] → [concrete fix]   (omit when none)

### Worth improving
- [finding] → [fix]

### Narrative   (from dvt-narrative-critic)
[verdict + the key points]

### Layout   (from dvt-layout-critic, incl. deterministic lint)
[verdict + the key points]
```

## Step 5 — offer next step

On **GO**, offer to apply: `dvt_dashboard_apply_spec(spec, preview=true)` first (show the plan +
any provenance/lint suggestions), then apply without preview to persist. On **REVISE FIRST**, offer to
make the must-fix changes, then re-run `/dvt:dvt-review` on the revised spec.
