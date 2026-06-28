# OpenCode Container w. Node & Python

Docker container for [OpenCode](https://opencode.ai) - the open source AI coding agent.

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
```

> ⚠️ **Security:** `OPENCODE_HOSTNAME=0.0.0.0` is required for the published port to be reachable, but it exposes an **unauthenticated** agent with full file & shell access. Run it only on a trusted local network, or set `OPENCODE_SERVER_PASSWORD`.

**With persistence:**

```bash
docker run -d \
  -p 4096:4096 \
  -e OPENCODE_PORT=4096 \
  -e OPENCODE_HOSTNAME=0.0.0.0 \
  -e OPENCODE_CONFIG=/config/opencode.json \
  -v ./config:/config \
  -v ./data:/data \
  -v ./projects:/projects \
  vinnyahh/opencode-box:latest
```

Access at http://localhost:4096

## Environment Variables

| Variable                   | Description          | Default     |
| -------------------------- | -------------------- | ----------- |
| `OPENCODE_PORT`            | Server port          | `4096`      |
| `OPENCODE_HOSTNAME`        | Server hostname      | `127.0.0.1` |
| `OPENCODE_CONFIG`          | Path to config file | -           |
| `OPENCODE_SERVER_PASSWORD` | Basic auth password | -           |

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
├── agents/            # Custom agents
├── commands/          # Custom commands
├── plugins/           # Custom plugins
├── themes/            # Custom themes
├── tools/             # Custom tools
├── skills/            # Custom skills
└── modes/             # Custom modes

data/
├── auth.json          # API credentials (auto-generated)
├── mcp-auth.json      # MCP OAuth tokens (auto-generated)
├── sessions/          # Conversation history
├── snapshots/         # Session checkpoints
└── log/               # Log files

projects/
└── (your code)        # Your project files
```

## MCP Server Support

This container supports running MCP (Model Context Protocol) servers:

| MCP Server Type  | Runtime | Example Command                              |
| ---------------- | ------- | -------------------------------------------- |
| Node.js packages | `npx`   | `npx -y @modelcontextprotocol/server-github` |
| Python packages  | `uvx`   | `uvx mcp-server-sqlite`                      |
| Remote servers   | HTTP    | URL in config                                |

See [opencode.json](https://github.com/vinnyahh/opencode-box/blob/master/config/opencode.json) for a full example.

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

## Operation

### Entrypoint

The [`docker-entrypoint.sh`](docker-entrypoint.sh) handles startup automatically:

- **Config auto-detection** — Looks for `/config/opencode.jsonc` first, then `/config/opencode.json`. Override with the `OPENCODE_CONFIG` environment variable.
- **Directory linking** — Symlinks `/config` → `~/.config/opencode` and `/data` → `~/.local/share/opencode` so OpenCode finds them in their default locations.
- **Debug mode** — Set `DEBUG=true` to print version info, PATH, config and symlink status on startup.

### Healthcheck

The container has a built-in [`HEALTHCHECK`](Dockerfile#L42-L43) that pings the OpenCode server every 30s. Works with Docker's health status and orchestration tools.

## License

MIT
