# Clawder — Replication Config

This directory captures every config and prompt needed to reproduce the **Rook** 🧭 agent environment.

## Structure

```
config/
├── README.md                     ← this file
├── workspace/                    ← workspace files (SOUL, IDENTITY, prompts, tools)
│   ├── AGENTS.md                 ← agent behavior and conventions
│   ├── SOUL.md                   ← personality and operational ethos
│   ├── IDENTITY.md               ← name, emoji, creature, vibe
│   ├── USER.md                   ← human profile (Dav)
│   ├── TOOLS.md                  ← tool notes (Instagram data collection)
│   └── BOOTSTRAP.md              ← first-run wake-up script
└── gateway/
    ├── openclaw.json             ← gateway config (templatized — fill in $ vars)
    └── auth-profiles.json        ← API keys (templatized — fill in $ vars)
```

## Steps to Replicate

### 1. Build + start the container

```bash
cd ~/clawder
cp .env.example .env
# Fill in .env:
#   VNC_PW=<desktop password>
#   OPENCLAW_GATEWAY_PASSWORD=<gateway UI password>
#   DEEPSEEK_API_KEY=<your DeepSeek key>

docker compose build
docker compose up -d
```

### 2. Replace gateway config with the Rook config

Once the container is running and the gateway has onboarded once:

```bash
# Copy templatized configs into the container
docker compose exec kasm-openclaw bash -c "
  # Replace openclaw.json with our version (fill in the token from the auto-generated one)
  cp config/gateway/openclaw.json ~/.openclaw/openclaw.json
  cp config/gateway/auth-profiles.json ~/.openclaw/agents/main/agent/auth-profiles.json
"
```

Or wait for the container's auto-onboarding to produce a config, then merge our workspace files into it.

### 3. Deploy workspace files

The desktop autostart copies workspace files on first-run (see `docker-compose.yml` or add a bind mount). To deploy manually:

```bash
docker compose exec kasm-openclaw bash -c "
  cp -r /opt/clawder/config/workspace/* ~/.openclaw/workspace/
"
```

Add a volume to `docker-compose.yml` to persist the workspace:

```yaml
volumes:
  - ./config/workspace:/opt/clawder/config/workspace
```

### 4. Restart the gateway

```bash
docker compose restart kasm-openclaw
```

Or kill the gateway process inside the desktop:

```bash
docker compose exec kasm-openclaw pkill -f "openclaw.*gateway"
```

The autostart script will restart it automatically.

## Variables to Fill In

| Variable | Where | Description |
|----------|-------|-------------|
| `${OPENCLAW_GATEWAY_TOKEN}` | `config/gateway/openclaw.json` | Auto-generated gateway auth token (set during onboarding) |
| `${DEEPSEEK_API_KEY}` | `config/gateway/auth-profiles.json`, `.env` | Your DeepSeek API key |
| `${ONBOARDED_AT}` | `config/gateway/openclaw.json` | ISO timestamp of onboarding |
| `${OPENCLAW_VERSION}` | `config/gateway/openclaw.json` | OpenClaw version tag (e.g. 2026.6.1) |

On first run, the auto-onboarding script generates these values. You can extract them:

```bash
docker compose exec kasm-openclaw cat ~/.openclaw/openclaw.json | jq '.gateway.auth.token'
docker compose exec kasm-openclaw cat ~/.openclaw/openclaw.json | jq '.meta.lastTouchedVersion'
docker compose exec kasm-openclaw cat ~/.openclaw/openclaw.json | jq '.meta.lastTouchedAt'
```

## Key Differences from Stock Config

- **Model input includes `"image"`** for DeepSeek V4 Flash — enables reading screenshots/images during data collection
- **Workspace files tuned for Instagram data collection** with humanized browsing patterns
- **SOUL.md** defines the Rook persona — strategic, adaptive, undetectable
