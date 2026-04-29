#!/usr/bin/env bash
set -euo pipefail

PORT="${PORT:-8080}"

# Inject the Cloud Run / host-assigned port into gateway config
sed -i "s/^port=.*/port=${PORT}/" /etc/falahos/gateway.ini

mkdir -p /var/run/falahos /var/log/falahos

# ── 1. Message Bus ────────────────────────────────────────────────
/usr/local/bin/falahos-message-bus >> /var/log/falahos/message-bus.log 2>&1 &
MB_PID=$!

echo "[entrypoint] waiting for message-bus..."
until [ -f /var/run/falahos/message-bus.url ]; do sleep 1; done

# ── 2. Gateway ────────────────────────────────────────────────────
/usr/local/bin/falahos-gateway -w /var/lib/falahos/www >> /var/log/falahos/gateway.log 2>&1 &
GW_PID=$!

echo "[entrypoint] waiting for gateway management URL..."
until [ -f /var/run/falahos/management.url ]; do sleep 1; done

# ── 3. Core ───────────────────────────────────────────────────────
/usr/local/bin/falahos-core -c /etc/falahos/falahos.conf >> /var/log/falahos/core.log 2>&1 &
CORE_PID=$!

# ── 4. AppManagement (skipped if no Docker socket) ───────────────
if [ -S /var/run/docker.sock ]; then
  /usr/local/bin/falahos-appmgmt -c /etc/falahos/app-management.conf \
    >> /var/log/falahos/appmgmt.log 2>&1 &
  APPMGMT_PID=$!
else
  echo "[entrypoint] no Docker socket — skipping app-management"
  APPMGMT_PID=""
fi

echo "[entrypoint] all services started — gateway on port ${PORT}"

# Keep the container alive; exit if any core service dies
wait $MB_PID $GW_PID $CORE_PID ${APPMGMT_PID:-}
