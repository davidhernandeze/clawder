#!/usr/bin/env bash
#
# Launches the OpenClaw gateway inside the Kasm desktop session.
# Invoked once per session by the XFCE autostart entry (openclaw.desktop).
set -euo pipefail

APP_DIR=/opt/openclaw
CONFIG_DIR="${OPENCLAW_CONFIG_DIR:-$HOME/.openclaw}"
LOG="$CONFIG_DIR/gateway.log"

mkdir -p "$CONFIG_DIR"
cd "$APP_DIR"

# The gateway port (18789) is published to the host, so it must bind a non-loopback
# address — and OpenClaw refuses that without auth. A password is required.
: "${OPENCLAW_GATEWAY_PASSWORD:?set OPENCLAW_GATEWAY_PASSWORD (see .env) — the gateway will not bind the published port without auth}"

# First-run onboarding (idempotent via sentinel). stdin is closed (</dev/null) so the
# CLI stays non-interactive instead of waiting on a prompt that never comes.
if [ ! -f "$CONFIG_DIR/.onboarded" ]; then
  if [ -n "${DEEPSEEK_API_KEY:-}" ]; then
    echo "[start-openclaw] onboarding with DeepSeek provider (deepseek/deepseek-v4-flash)..." | tee -a "$LOG"
    node openclaw.mjs onboard --non-interactive --mode local \
      --auth-choice deepseek-api-key --deepseek-api-key "$DEEPSEEK_API_KEY" \
      --skip-health --accept-risk </dev/null >>"$LOG" 2>&1 \
      && touch "$CONFIG_DIR/.onboarded"
  else
    echo "[start-openclaw] no provider key set; creating a local config (set one in the UI)..." | tee -a "$LOG"
    node openclaw.mjs onboard --non-interactive --mode local \
      --skip-health --accept-risk </dev/null >>"$LOG" 2>&1 \
      && touch "$CONFIG_DIR/.onboarded" || true
  fi
fi

# Bind lan + password auth (port is published to the host). If onboarding didn't
# produce a config, fall back to --dev so the gateway self-creates one and still starts.
GATEWAY_FLAGS="--bind lan --auth password"
[ -f "$CONFIG_DIR/.onboarded" ] || GATEWAY_FLAGS="--dev $GATEWAY_FLAGS"

echo "[start-openclaw] starting gateway on :18789 ($GATEWAY_FLAGS)" | tee -a "$LOG"
exec node openclaw.mjs gateway $GATEWAY_FLAGS </dev/null >>"$LOG" 2>&1
