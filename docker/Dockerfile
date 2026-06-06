# syntax=docker/dockerfile:1
#
# Kasm Linux desktop (Ubuntu 22.04 / XFCE, streamed to the browser over KasmVNC)
# with the OpenClaw computer-use agent running INSIDE the desktop session.
#
# OpenClaw's prebuilt app is copied from its official multi-arch image rather than
# compiled from source — much faster, and the official image is arm64-native so the
# binaries match this host's CPU. We run it on Node 24 installed for jammy (glibc 2.35).
#
# The Kasm container is the sandbox: OpenClaw runs unsandboxed within it
# (OPENCLAW_SANDBOX=none) and drives this desktop's own browser/terminal, isolated
# from the host. See README.md.

# Build args used in FROM lines must be declared before the first FROM (global scope).
# Prebuilt OpenClaw app (dist + node_modules + openclaw.mjs at /app):
ARG OPENCLAW_IMAGE=ghcr.io/openclaw/openclaw:latest
# kasmweb/ubuntu-jammy-desktop is the multi-arch (amd64 + arm64) full XFCE desktop,
# so it builds natively on Apple Silicon. (kasmweb/desktop is amd64-only.)
ARG KASM_TAG=1.17.0

FROM ${OPENCLAW_IMAGE} AS openclaw

FROM kasmweb/ubuntu-jammy-desktop:${KASM_TAG}

USER root

# ---- Node 24 runtime to execute OpenClaw (built for jammy/glibc 2.35) ----
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl ca-certificates \
    && curl -fsSL https://deb.nodesource.com/setup_24.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*

# ---- Prebuilt OpenClaw app from the official image ----
COPY --from=openclaw /app /opt/openclaw

# ---- Startup wiring: launch OpenClaw when the XFCE session starts ----
COPY docker/startup/start-openclaw.sh /usr/local/bin/start-openclaw.sh
COPY docker/startup/openclaw.desktop /home/kasm-user/.config/autostart/openclaw.desktop
RUN chmod +x /usr/local/bin/start-openclaw.sh

# ---- OpenClaw runtime defaults (container itself is the sandbox) ----
ENV OPENCLAW_SANDBOX=none \
    OPENCLAW_CONFIG_DIR=/home/kasm-user/.openclaw \
    OPENCLAW_WORKSPACE_DIR=/home/kasm-user/.openclaw/workspace \
    OPENCLAW_AUTH_PROFILE_SECRET_DIR=/home/kasm-user/.config/openclaw \
    PLAYWRIGHT_BROWSERS_PATH=/home/kasm-user/.cache/ms-playwright

# Kasm runs the desktop as uid 1000 / gid 0.
RUN mkdir -p /home/kasm-user/.openclaw/workspace /home/kasm-user/.config/openclaw \
    && chown -R 1000:0 /home/kasm-user /opt/openclaw

USER 1000

EXPOSE 6901 18789

# Keep Kasm's original ENTRYPOINT/CMD — the desktop boots normally and the
# autostart entry starts OpenClaw inside the session.
