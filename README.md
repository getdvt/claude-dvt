# claude-dvt

The dvt Claude Code plugin — a thin client for [dvt](https://dvt.dev) (data viz tool).

dvt is an AI-native approach to data visualization: data teams design, generate, and deploy
dashboards through a spec-driven workflow, where a dashboard is a versioned JSON spec that humans
and agents author the same way. This plugin brings that workflow into Claude Code. It is a **thin
client** — it carries no data and no compute. It bundles two things:

- the **dvt dashboard-spec authoring skill**, so an agent knows how to read, write, and validate a
  dvt dashboard spec; and
- an **MCP client** pointed at a dvt endpoint, so the agent can design, validate, render, and apply
  specs against a live dvt instance.

The plugin is open and ungated. It contains no secret and no entitlement logic — your access is
governed entirely by the dvt endpoint and the key you connect with.

## Install

In any Claude Code session:

```
/plugin marketplace add github.com/getdvt/claude-dvt
/plugin install dvt@claude-dvt
```

Then restart Claude Code (plugins don't hot-load).

## Connect

The plugin talks to a dvt endpoint over MCP. Point it at one of two targets:

- **dvt Gallery (hosted)** — connect to `https://mcp.dvt.dev/mcp` with a Gallery API key. Mint a key
  in your dvt workspace (`/app/api-keys`), then paste the `dvt_live_…` value when the plugin prompts
  for it. The key is stored by Claude Code, never committed here.
- **Self-hosted engine** — point the client at your own dvt engine URL instead. Use this if you run
  the dvt stack yourself.

> The plugin never embeds a key, an endpoint default that grants access, or any entitlement check.
> What you can do is decided by your dvt endpoint and the scopes on the key you provide.

<!-- TODO DVT-199: ship the actual connect flow. The MCP client config (which endpoint, how the
     dvt_live_… key / self-host URL is supplied to the MCP server) lands in DVT-199. Until then this
     section documents the intended UX; the wiring is not yet present in this repo. -->

## What's inside

```
.claude-plugin/
  marketplace.json     single-plugin marketplace so /plugin marketplace add resolves this repo
plugins/dvt/
  .claude-plugin/
    plugin.json        plugin manifest (name "dvt", semver)
  skills/              dvt dashboard-spec authoring skill   (TODO DVT-199)
  .mcp.json            MCP client config → dvt endpoint      (TODO DVT-199)
  commands/connect.md  /dvt:connect first-run setup/auth     (TODO DVT-199)
LICENSE                Apache-2.0
```

<!-- TODO DVT-199: add plugins/dvt/skills/ (the dashboard-spec authoring skill, vendored from the
     canonical dvt repo), plugins/dvt/.mcp.json (the MCP client config), and plugins/dvt/commands/
     connect.md (the setup flow). This scaffold (DVT-198) only establishes the repo, the resolvable
     manifest, and the marketplace listing. -->

## License

[Apache-2.0](./LICENSE). dvt is an open funnel artifact — this plugin matches the spec and SDK
licensing.
