# OpenCode Container w. Node & Python

Docker container for [OpenCode](https://opencode.ai) **v2** - the open source AI coding agent.

## What's Included

- **OpenCode AI** - Pinned to a specific version (`.opencode-version`) for reproducible builds
- **Node.js** - Latest from node:alpine base image, for npm-based MCP servers (`npx`)
- **Python 3** + **pip** - For Python-based MCP servers (`uvx`) and pip packages
- **uv** - Fast Python package manager
- **git** - Version control
- **ripgrep (rg)** - Fast code search
- **jq** - Command-line JSON processor
- **curl** - HTTP requests
- **bash** - Shell scripting
- **tar** - Archive extraction
- **Alpine Linux** - Minimal base image

## Quick Start

**Minimal (ephemeral - data lost on restart):**

```bash
docker run -d -p 4096:4096 -e OPENCODE_HOSTNAME=0.0.0.0 vinnyahh/opencode-box:latest

# v2 always password-protects the server; with no OPENCODE_SERVER_PASSWORD set
# it generates one and prints it at startup. Fetch it with:
docker logs <container> | grep 'server password'
```

> ⚠️ **Security:** `OPENCODE_HOSTNAME=0.0.0.0` is required for the published port to be reachable. In v2 the server is **always password-protected**: with `OPENCODE_SERVER_PASSWORD` set it uses your password; otherwise it generates one and prints it at startup. Connecting clients authenticate with the same value via `OPENCODE_PASSWORD`.

**With persistence:**

```bash
docker run -d \
  -p 4096:4096 \
  -e OPENCODE_PORT=4096 \
  -e OPENCODE_HOSTNAME=0.0.0.0 \
  -e OPENCODE_SERVER_PASSWORD=change-me \
  -e OPENCODE_CONFIG=/config/opencode.json \
  -v ./config:/config \
  -v ./data:/data \
  -v ./projects:/projects \
  vinnyahh/opencode-box:latest
```

Access at http://localhost:4096 and log in with the server password.

## Environment Variables

| Variable                   | Description                                                                        | Default        |
| -------------------------- | ---------------------------------------------------------------------------------- | -------------- |
| `OPENCODE_PORT`            | Server port                                                                        | `4096`         |
| `OPENCODE_HOSTNAME`        | Server hostname                                                                    | `127.0.0.1`    |
| `OPENCODE_CONFIG`          | Path to config file                                                                | auto-detect    |
| `OPENCODE_SERVER_PASSWORD` | Server password (web UI login, pairing, client auth)                               | auto-generated |
| `OPENCODE_PASSWORD`        | Also read server-side as the password; how connecting **clients** pass the password | -              |
| `DEBUG=true`               | Entrypoint debug output (versions, PATH, config and symlink status)                | -              |

## Volumes

| Path        | Description                       |
| ----------- | --------------------------------- |
| `/config`   | OpenCode config, agents, commands |
| `/data`     | Sessions, auth, logs              |
| `/projects` | Your project files                |

Expected structure:

```
config/
├── opencode.json      # Main config file
├── agents/            # Custom agents (markdown) — preferred v2 location
├── commands/          # Custom commands
├── plugins/           # Custom plugins (v2 plugins use the @opencode/plugin API)
├── skills/            # Custom skills
├── themes/            # Custom themes
└── tools/             # Custom tools

data/
├── opencode.db        # All sessions & messages (SQLite)
├── auth.json          # API credentials (auto-generated)
├── mcp-auth.json      # MCP OAuth tokens (auto-generated)
├── snapshot/          # Session checkpoints
└── log/               # Log files

projects/
└── (your code)        # Your project files
```

Legacy v1 directories are still discovered by v2: `mode/` and `modes/` (entries load as
**primary** agents), `agent/` alongside `agents/`, `command/` alongside `commands/`,
`plugin/` alongside `plugins/`, and `skill/` alongside `skills/`. Prefer the singular
v2 locations above for anything new.

## MCP Server Support

This container supports running MCP (Model Context Protocol) servers:

| MCP Server Type  | Runtime | Example Command                              |
| ---------------- | ------- | -------------------------------------------- |
| Node.js packages | `npx`   | `npx -y @modelcontextprotocol/server-github` |
| Python packages  | `uvx`   | `uvx mcp-server-sqlite`                      |
| Remote servers   | HTTP    | URL in config                                |

> v2 transparently normalizes legacy v1-style `mcp` blocks. The native v2 shape groups
> servers under `mcp.servers` and uses `disabled` instead of `enabled`. Both load fine —
> the [example config](https://github.com/vinnyahh/opencode-box/blob/master/config/opencode.json)
> intentionally keeps the v1 shape.

## Browser Access

The container can be paired with a browser for frontend testing, visual verification, and DevTools-based workflows. Two approaches:

### 1. Chrome Remote Debugging (Host → Container)

Run Chrome on your host machine with remote debugging enabled, then configure the MCP to connect through Docker's host gateway:

```bash
# On your host machine (macOS/Linux):
chrome --remote-debugging-port=9222 --no-sandbox

# Point the MCP at the host's Chrome from inside the container:
#  MCP server URL: http://host.docker.internal:9222/json
```

**No changes to the container** — Chrome runs on the host. All DevTools tools (snapshot, click, fill, evaluate, performance, etc.) work over this connection.

### 2. Playwright / Puppeteer (Inside Container)

For CI-style environments or when you don't want to depend on a host browser, add Playwright or Puppeteer to your setup — they bundle their own Chromium:

```bash
# In your Dockerfile or at runtime:
npx playwright install chromium
```

This approach works out-of-the-box in the container but uses Playwright/Puppeteer APIs directly rather than the Chrome DevTools MCP protocol.

> **Alpine/musl caveat:** Playwright/Puppeteer's downloaded browsers are glibc (Ubuntu)
> builds and fail on this musl image with `spawn ENOENT` / "required file not found".
> Use Alpine's musl-native Chromium instead: `apk add chromium` and point Playwright
> (or the browser MCP) at `--executable-path /usr/bin/chromium`.

## Operation

### Entrypoint

The [`docker-entrypoint.sh`](docker-entrypoint.sh) handles startup automatically:

- **Config auto-detection** — Looks for `/config/opencode.jsonc` first, then `/config/opencode.json`. Override with the `OPENCODE_CONFIG` environment variable.
- **Directory linking** — Symlinks `/config` → `~/.config/opencode` and `/data` → `~/.local/share/opencode`, but **only when the default paths are free**. Mounting state directly at the defaults (e.g. `-v ~/.config/opencode:/root/.config/opencode`) works equally well and skips the symlinks entirely.
- **Debug mode** — Set `DEBUG=true` to print version info, PATH, config and symlink status on startup.

### Healthcheck

The container has a built-in [`HEALTHCHECK`](Dockerfile) that requests `/` every 30s via `127.0.0.1` — v2 binds IPv4 only, so `localhost` would first resolve to `::1` and report connection refused. Works with Docker's health status and orchestration tools.

## License

MIT