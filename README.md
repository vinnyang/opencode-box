# OpenCode Container w. Node & Python

Docker container for [OpenCode](https://opencode.ai) - the open source AI coding agent.

## What's Included

- **OpenCode AI** - Latest version from official installer (opencode.ai/install)
- **Node.js** - Latest from node:alpine base image, for npm-based MCP servers (`npx`)
- **Python 3** - For Python-based MCP servers (`uvx`)
- **uv** - Fast Python package manager
- **Alpine Linux** - Minimal base image

## Quick Start

**Minimal (ephemeral - data lost on restart):**

```bash
docker run -d -p 4096:4096 vinnyahh/opencode-box:latest
```

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

See [opencode.jsonc](https://github.com/vinnyahh/opencode-box/blob/master/config/opencode.jsonc) for a full example.

## Docker Compose

```bash
docker-compose up -d
```

## License

MIT
