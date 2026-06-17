---
description: Connect this plugin to a dvt endpoint (dvt Gallery or a self-hosted engine), then verify the connection.
---

# /dvt:connect — connect to dvt

You are walking the user from a fresh install to a working dvt connection. The user may not be
technical. Be concise, ask one thing at a time, and never print or echo their API key back to them.

The plugin bundles no MCP server of its own — this command registers one. For dvt Gallery you
register an authenticated, user-scoped `dvt` server; for self-host you point it at the user's engine
URL. The key (if any) is stored only in the user's local Claude config — never write it to a file in
this repo or anywhere in the project.

## Step 1 — pick a backend

Ask the user:

> Are you connecting to **dvt Gallery** (the hosted service at dvt.dev) or a **self-hosted dvt
> engine** that you run yourself?

Branch on their answer.

## Step 2a — dvt Gallery (hosted)

1. Tell them to mint a key:

   > Open **https://app.dvt.dev/app/api-keys**, create a new API key, and copy it. It looks like
   > `dvt_live_…` and is shown only once. Paste it here when ready.

2. When they paste the key, register an authenticated, user-scoped `dvt` MCP server. Run this exact
   command, substituting the key they gave you for `<KEY>` (do not print the key in your reply):

   ```bash
   claude mcp add --transport http --scope user dvt "https://mcp.dvt.dev/mcp" --header "Authorization: Bearer <KEY>"
   ```

   If a `dvt` server already exists at user scope (e.g. they're re-running connect with a new key),
   remove it first with `claude mcp remove --scope user dvt`, then re-add.

3. Tell the user they must **restart Claude Code** for the new MCP server to take effect, then return
   and run `/dvt:connect` again (or just ask you to list their dashboards) to verify.

## Step 2b — self-hosted engine

1. Ask for their engine's MCP URL:

   > What is your dvt engine's MCP URL? For a local engine it's usually
   > `http://localhost:8001/mcp` (the engine's default port is 8001).

2. Register it as a user-scoped `dvt` server with no auth header. If a `dvt` server already exists at
   user scope (e.g. they're switching from Gallery, or re-pointing at a new engine), remove it first
   with `claude mcp remove --scope user dvt`, then add:

   ```bash
   claude mcp add --transport http --scope user dvt "<ENGINE_URL>"
   ```

   If their engine fronts requests with its own bearer token, add
   `--header "Authorization: Bearer <THEIR_KEY>"` the same way as the Gallery flow.

3. Tell them to **restart Claude Code**, then verify.

## Step 3 — verify

After the user has restarted, confirm the connection by calling any cheap read tool the `dvt` MCP
server exposes (e.g. listing dashboards). If the tool returns (even an empty list), the connection
works: tell them so.

If it fails, map the error:

- **401 Unauthorized** → the key is wrong, expired, or revoked. Have them mint a fresh key at
  https://app.dvt.dev/app/api-keys and re-run Step 2a.
- **403 Forbidden** → the key is valid but lacks the scope (or the workspace tier) for this action.
  Point them at their key's scopes in the dvt app.
- **Connection refused / cannot reach host** → the URL is wrong or the engine isn't running. For
  self-host, double-check the engine URL and that the engine is up.
- **Server not found / no `dvt` tools** → the MCP server didn't load. Confirm they restarted Claude
  Code after Step 2, and that `claude mcp list` shows a `dvt` server.

## Step 4 — hand off to authoring

Once verified, point them at the bundled skill:

> You're connected. Now just ask me to build a dashboard — for example: "build a pipeline-health
> dashboard from this data." I'll author a dvt spec and we can apply it to your dvt instance.
