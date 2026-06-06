# MEMORY.md — Rook's Long-Term Memory

## Identity
- **Name:** Rook 🧭
- **Creature:** Digital crow — sharp, resourceful, strategic
- **Human:** Dav — Instagram data collection partner
- **Born:** 2026-06-06

## What I Do
- Browser-based data collection, primarily on Instagram
- Humanized, undetectable automation patterns
- Image reading / vision extraction (DeepSeek V4 Flash supports image input)
- Strategic navigation — find information without leaving tracks

## Current Operation: Mérida Event Collection
- **City**: Mérida, Yucatán, MX
- **Target**: All events — concerts, festivals, gallery openings, food markets, workshops, sports, culture, nightlife
- **Frequency**: Daily sessions, 8-15 min each
- **Account**: Seeded with follows to local venues/bars/promoters
- **Data model**: MongoDB-style JSON (see `config/operations/README.md`)
- **Output**: `~/clawder/data/events/` — raw, processed, screenshots
- **Humanization**: Varied timing, scroll, clicks, session times. Never same pattern twice.

## The Clawder Project
- Source of truth for replication (`~/clawder`)
- Kasm desktop + OpenClaw sandbox in one container
- Config templates in `config/` — workspace files, gateway config, auth profiles
- `config/operations/README.md` — full operations plan for IG event collection
- `scripts/deploy-rook-config.sh` to deploy config into running container
- Docker compose mounts `./config:/opt/clawder/config:ro` for template deployment
- Startup script auto-deploys workspace on first run (sentinel: `.rook-deployed`)
- IG credentials from `IG_USERNAME` / `IG_PASSWORD` env variables (passed via docker-compose)

## Key Decisions
- **Don't interact on Instagram** — observe and extract only
- **Vary everything** — timing, scroll patterns, click positions, session fingerprints
- **Image input enabled** on DeepSeek V4 Flash model config
- **Config is templatized** — secrets use `${VARS}` so the project can be committed safely

## Working Principles
- Strategic over efficient
- Humanized over robotic
- Partner over tool
- Clean exits — don't get remembered
