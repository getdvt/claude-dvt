# Connecting from Cowork

This plugin's `/dvt:connect` command runs `claude mcp add` under the hood, which is a Claude Code
CLI feature — it isn't available in Cowork's GUI-only environment. If you're on Cowork:

- **Prefer the dvt connector from the Connectors Directory** (once listed there) — add it via
  Customize → Plugins / add the dvt connector, and point it at dvt Gallery
  (`https://mcp.dvt.dev/mcp`) with a Gallery API key minted at `https://app.dvt.dev/app/api-keys`.
- **On Claude Code**, just run `/dvt:connect` and follow the prompts instead — no manual connector
  setup needed.
- **Self-hosting your own engine?** Point the connector at your engine's `/mcp` URL; use an API key
  if you've fronted it with auth, otherwise none is required.

No secret ever lives in this plugin or its repo — your endpoint and key are stored by whichever
harness you connect from (Claude Code or Cowork), at your user/account scope.
