#!/usr/bin/env bash
#
# Deploy the Rook agent config into a running clawder container.
# Run this from the clawder project root.
set -euo pipefail

cd "$(dirname "$0")/.."

echo "=== Deploying Rook config ==="

# 1. Extract real values from the running container's auto-generated config
echo "[1/4] Extracting gateway token from running container..."
TOKEN=$(docker compose exec kasm-openclaw bash -c "cat ~/.openclaw/openclaw.json 2>/dev/null" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['gateway']['auth']['token'])" 2>/dev/null || echo "")
if [ -z "$TOKEN" ]; then
  echo "  ⚠ Could not extract token. Is the container running and onboarded?"
  echo "  Continuing with template token (you'll need to fill it in manually)."
  TOKEN="__FILL_ME_IN__"
fi

ONBOARDED_AT=$(docker compose exec kasm-openclaw bash -c "cat ~/.openclaw/openclaw.json 2>/dev/null" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['meta']['lastTouchedAt'])" 2>/dev/null || echo "2026-01-01T00:00:00.000Z")
VERSION=$(docker compose exec kasm-openclaw bash -c "cat ~/.openclaw/openclaw.json 2>/dev/null" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['meta']['lastTouchedVersion'])" 2>/dev/null || echo "2026.6.1")

# 2. Get API key from .env
echo "[2/4] Reading API key from .env..."
API_KEY=$(grep -oP '^DEEPSEEK_API_KEY=\K.*' .env 2>/dev/null || echo "")
if [ -z "$API_KEY" ]; then
  echo "  ⚠ DEEPSEEK_API_KEY not found in .env"
  API_KEY="__FILL_ME_IN__"
fi

# 3. Generate gateway config with real values
echo "[3/4] Writing gateway config..."
docker compose exec -T kasm-openclaw bash -c "mkdir -p ~/.openclaw && cat > ~/.openclaw/openclaw.json" < <(
  sed -e "s/\${OPENCLAW_GATEWAY_TOKEN}/$TOKEN/" \
      -e "s/\${ONBOARDED_AT}/$ONBOARDED_AT/" \
      -e "s/\${OPENCLAW_VERSION}/$VERSION/" \
      config/gateway/openclaw.json
)

# 4. Write auth profiles
echo "[4/4] Writing auth profiles..."
docker compose exec -T kasm-openclaw bash -c "mkdir -p ~/.openclaw/agents/main/agent && cat > ~/.openclaw/agents/main/agent/auth-profiles.json" < <(
  sed -e "s/\${DEEPSEEK_API_KEY}/$API_KEY/" \
      config/gateway/auth-profiles.json
)

echo ""
echo "=== ✅ Rook config deployed! ==="
echo "Restart the gateway to apply:"
echo "  docker compose exec kasm-openclaw pkill -f 'openclaw.*gateway'"
echo ""
