# clawder — Kasm desktop + OpenClaw sandbox

# 🧭 Clawder — Kasm desktop + OpenClaw sandbox

A single-container **Kasm Workspace** Linux desktop (Ubuntu 22.04 / XFCE on the multi-arch
`kasmweb/ubuntu-jammy-desktop` base — builds natively on Apple Silicon, streamed to your
browser over KasmVNC) with the [OpenClaw](https://github.com/openclaw/openclaw)
computer-use agent built in and running **inside** the desktop session.

This repo is pre-configured for **undetectable Instagram data collection** using the
**Rook 🧭** agent persona — a humanized, strategic browser agent that reads images,
varies its patterns, and avoids bot detection.

## Why this shape

OpenClaw has shell, filesystem, and browser control and normally spawns its *own* Docker
sandbox for actions. Here the **Kasm container is the sandbox**: OpenClaw runs unsandboxed
within it (`OPENCLAW_SANDBOX=none`) and drives this desktop's own browser/terminal for
data extraction, fully isolated from your host. You watch (and take over) the agent live
in the streamed desktop.

```
host ──┬─ https://localhost:6901   →  Kasm XFCE desktop (you drive / observe)
       └─ http://localhost:18789   →  OpenClaw gateway UI
                    │
              one container: OpenClaw + browser + shell (the sandbox)
```

## Prerequisites

- Docker Desktop with **Compose v2**.
- OpenClaw's prebuilt app is copied from its official multi-arch image (`ghcr.io/openclaw/openclaw`),
  so the build is fast and light — no source compile. The base desktop image is ~1.5 GB to pull.

## Quick start

```bash
cp .env.example .env
# edit .env: set VNC_PW and exactly ONE LLM provider (see below)

docker compose build      # copies OpenClaw from its prebuilt image; fast
docker compose up -d
```

Then:

1. **Desktop:** open **https://localhost:6901** → accept the self-signed certificate →
   log in with username `kasm_user` and the `VNC_PW` from your `.env`.
2. The XFCE desktop loads and the OpenClaw gateway auto-starts in the session.
3. **Agent:** open the OpenClaw UI at **http://localhost:18789** (or inside the desktop's
   own browser) → log in with `OPENCLAW_GATEWAY_PASSWORD` from your `.env` → finish provider
   setup in the UI.

> The gateway runs with `--dev` (creates a local config + workspace on first start, no
> interactive onboarding) and `--auth password` (required because port 18789 is published
> to your host). Both are wired in `docker/startup/start-openclaw.sh`.

## Choosing an LLM provider

Set one of these in `.env`:

| Provider            | Variable            | Value                                   |
|---------------------|---------------------|-----------------------------------------|
| Anthropic (Claude)  | `ANTHROPIC_API_KEY` | your key                                |
| OpenAI              | `OPENAI_API_KEY`    | your key                                |
| Local (Ollama)      | `OLLAMA_BASE_URL`   | `http://host.docker.internal:11434`     |
| Local (LM Studio)   | `OLLAMA_BASE_URL`   | `http://host.docker.internal:1234`      |

`host.docker.internal` resolves to your Mac, so a local model server on the host is
reachable from inside the container.

## Persistence

Config, workspace, and auth secrets are bind-mounted to `./data/` so they survive
rebuilds:

- `./data/openclaw` → `/home/kasm-user/.openclaw` (config + workspace + `gateway.log`)
- `./data/config`   → `/home/kasm-user/.config/openclaw` (auth secrets)

## Operating it

```bash
docker compose logs -f                                            # container logs
docker compose exec kasm-openclaw tail -f ~/.openclaw/gateway.log # OpenClaw logs
docker compose exec kasm-openclaw curl -s localhost:18789/readyz  # gateway readiness
docker compose down                                               # stop
```

## Pinning / upgrading

Both versions are build args (override in `.env` or on the CLI):

- `KASM_TAG` — Kasm desktop image tag ([kasmweb/ubuntu-jammy-desktop tags](https://hub.docker.com/r/kasmweb/ubuntu-jammy-desktop/tags); no `latest`).
- `OPENCLAW_IMAGE` — OpenClaw prebuilt image the app is copied from. Pin a version tag for
  reproducible builds: `OPENCLAW_IMAGE=ghcr.io/openclaw/openclaw:2026.2.26 docker compose build`.

## Files

```
config/                        ← Rook agent config + workspace for replication
  README.md                    ← how to replicate the agent environment
  workspace/                   ← SOUL.md, IDENTITY.md, AGENTS.md, TOOLS.md, etc.
  gateway/                     ← templatized gateway configs (openclaw.json, auth)
docker/
  Dockerfile                  # Kasm desktop + Node 24 + OpenClaw build
  startup/
    start-openclaw.sh         # onboard-once, then run the gateway (--bind lan)
    openclaw.desktop          # XFCE autostart entry → start-openclaw.sh
docker-compose.yml
.env.example
```

## Notes

- OpenClaw's app (`dist` + `node_modules` + `openclaw.mjs`) is copied from the official
  arm64-native image and run on Node 24 installed for jammy. Native deps ship as portable
  prebuilds, so they load on jammy's glibc 2.35.
- If the OpenClaw `gateway`/`onboard` CLI flags change upstream, adjust
  `docker/startup/start-openclaw.sh` (one-line tweaks).
