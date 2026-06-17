# Releasing the dvt plugin

This repo is a Claude Code **plugin marketplace**. There is no build or publish step: a release is a
version bump plus a git tag on `main`. Claude Code resolves the plugin straight from this public repo
when a user runs `/plugin marketplace add getdvt/claude-dvt`, so whatever is on `main` is what
installs. The version + tag exist so installs are reproducible and changes are auditable.

This mirrors the [dvt-org plugin release flow](https://github.com/getdvt/claude-org) — same shape,
so founders only have to learn it once.

## Versioning

The plugin version is the `version` field in
[`plugins/dvt/.claude-plugin/plugin.json`](./plugins/dvt/.claude-plugin/plugin.json), following
[semver](https://semver.org):

| Bump  | When |
|-------|------|
| patch | docs, copy, a `/dvt:connect` fix, a re-vendored skill with no behavior change |
| minor | a new command, a new capability, an additive change to the connect flow |
| major | a breaking change to a command's interface or the connect contract |

A re-vendored `skills/dvt-spec-author/SKILL.md` (see below) is at least a **patch** — it changes what
the plugin ships even though no code here changed.

## Cutting a release

1. Open a PR against `main` with the change.
2. Bump `version` in `plugins/dvt/.claude-plugin/plugin.json` (semver, per the table above).
3. Run [`/pr-review`](https://github.com/getdvt/claude-org) and get one founder to review + merge
   (`--squash`). CI (`plugin-validate`) must be green: valid JSON manifests, no committed secret, all
   required files present.
4. Tag the merge commit and push the tag:
   ```bash
   git checkout main && git pull
   git tag v$(python3 -c "import json;print(json.load(open('plugins/dvt/.claude-plugin/plugin.json'))['version'])")
   git push --tags
   ```
   Tag name is `v<version>` (e.g. `v0.1.0`), matching the `version` you just merged.

There is nothing to publish afterwards — the marketplace resolves the repo live.

## The vendored authoring skill — do not hand-edit

`plugins/dvt/skills/dvt-spec-author/SKILL.md` is **vendored byte-for-byte** from the canonical copy in
[`getdvt/dvt`](https://github.com/getdvt/dvt) and must never be edited here. To update it, re-vendor
from upstream `origin/main` (never a local checkout — that was the DVT-199 staleness bug):

```bash
./scripts/sync-from-dvt.sh
```

`.github/workflows/skill-drift.yml` is the backstop: it diffs the vendored skill against the canonical
copy served from `demo.dvt.dev` on every PR that touches it and weekly for upstream drift. A re-vendor
is its own release (patch bump + tag) so installs stay pinned to a known skill.
