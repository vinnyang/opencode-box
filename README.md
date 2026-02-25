# OpenCode Container w. Node & Python

Docker container for [OpenCode](https://opencode.ai) - the open source AI coding agent.

## What's Included

- **OpenCode AI** - Latest version from official installer (opencode.ai/install)
- **Node.js** - Latest from node:alpine base image, for npm-based MCP servers (`npx`)
- **Python 3** - For Python-based MCP servers (`uvx`)
- **uv** - Fast Python package manager
- **Alpine Linux** - Minimal base image

## MCP Server Support

This container supports running MCP (Model Context Protocol) servers for extending OpenCode's capabilities:

| MCP Server Type  | Runtime | Example Command                              |
| ---------------- | ------- | -------------------------------------------- |
| Node.js packages | `npx`   | `npx -y @modelcontextprotocol/server-github` |
| Python packages  | `uvx`   | `uvx mcp-server-sqlite`                      |
| Remote servers   | HTTP    | URL in config                                |

### Example MCP Config | [opencode.jsonc](https://github.com/vinnyang/opencode-box/blob/master/config/opencode.jsonc)

<img width="514" height="322" alt="image" src="https://github.com/user-attachments/assets/e95473c0-5bca-4b7b-89e3-0adc1a4ce7c5" />

Mount your `opencode.json` to override the placeholder JSON.

## Quick Start

```bash
docker run -d \
  -p 4096:4096 \
  -e OPENCODE_PORT=4096 \
  -e OPENCODE_HOSTNAME=0.0.0.0 \
  -e OPENCODE_CONFIG=/config/opencode.json \
  -v /path/to/config:/config \
  -v /path/to/data:/data \
  -v /path/to/projects:/projects \
  vinnyahh/opencode-box:latest
```

Access at http://localhost:4096

## Persistence

By default, session data is **ephemeral** (lost when container is destroyed).

For **persistent data** (sessions, auth, logs), mount the `/data` volume:

```bash
docker run -d \
  -v ./data:/data \
  vinnyahh/opencode-box:latest
```

### Persistent vs Ephemeral Mode

| Mode           | Command           | Use Case                           |
| -------------- | ----------------- | ---------------------------------- |
| **Persistent** | `-v ./data:/data` | Production, keep session history   |
| **Ephemeral**  | (no data mount)   | Testing, CI, fresh start each time |

## Environment Variables

| Variable                   | Description         | Default     |
| -------------------------- | ------------------- | ----------- |
| `OPENCODE_PORT`            | Server port         | `4096`      |
| `OPENCODE_HOSTNAME`        | Server hostname     | `127.0.0.1` |
| `OPENCODE_CONFIG`          | Path to config file | -           |
| `OPENCODE_SERVER_PASSWORD` | Basic auth password | -           |

## Docker Compose

```bash
docker-compose up -d
```

## Volumes

| Path        | Description                       | Persistent?             |
| ----------- | --------------------------------- | ----------------------- |
| `/config`   | OpenCode config, agents, commands | Mount for custom config |
| `/data`     | Sessions, auth, logs              | Mount for persistence   |
| `/projects` | Your project files                | Mount your code         |

## Directory Structure

When you mount volumes, OpenCode expects this structure:

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

## Building

```bash
docker build -t vinnyahh/opencode-box:latest .
```

## Docker Hub

[vinnyahh/opencode-box](https://hub.docker.com/r/vinnyahh/opencode-box)

## License

MIT
