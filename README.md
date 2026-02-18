# OpenCode Container w. Node

Docker container for [OpenCode](https://opencode.ai) - the open source AI coding agent.

## What's Included

- **OpenCode AI** - Latest version from npm (`opencode-ai`)
- **Node.js 25.x (Current)**
- **npm** - Node package manager (global)
- **Alpine Linux 3.23** - Minimal base image (~180MB)

## Quick Start

```bash
docker run -d \
  -p 4096:4096 \
  -e OPENCODE_PORT=4096 \
  -e OPENCODE_HOSTNAME=0.0.0.0 \
  -e OPENCODE_CONFIG=/config/opencode.json \
  -v /path/to/config:/config \
  -v /path/to/projects:/projects \
  vinnyahh/opencode-box:latest
```

Access at http://localhost:4096

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

| Path        | Description                  |
| ----------- | ---------------------------- |
| `/config`   | OpenCode configuration files |
| `/projects` | Your project files           |

## Building

```bash
docker build -t vinnyahh/opencode-box:latest .
```

## Docker Hub

[vinnyahh/opencode-box](https://hub.docker.com/r/vinnyahh/opencode-box)

## License

MIT
