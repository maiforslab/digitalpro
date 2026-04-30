#!/usr/bin/env bash
set -euo pipefail

PORT="${PORT:-8080}"

log() { echo "[entrypoint] $*"; }

# Gateway reads from /etc/casaos/gateway.ini (CasaOS-Common DefaultConfigPath)
sed -i "s/^port=.*/port=${PORT}/" /etc/casaos/gateway.ini

mkdir -p /var/run/casaos /var/lib/casaos/db /var/log/falahos

wait_for_file() {
  local file="$1" label="$2" deadline=$(( $(date +%s) + 90 ))
  until [ -f "$file" ]; do
    if [ "$(date +%s)" -ge "$deadline" ]; then
      log "ERROR: timed out waiting for $label ($file)"
      exit 1
    fi
    sleep 1
  done
  log "$label ready"
}

# ── 1 + 2. Message Bus and Gateway start together ────────────────
# message-bus waits internally for management.url (written by gateway).
# gateway waits internally for message-bus.url (written by message-bus).
# Starting both simultaneously breaks the circular wait.
log "starting message-bus..."
/usr/local/bin/falahos-message-bus 2>&1 | tee /var/log/falahos/message-bus.log &
MB_PID=$!

log "starting gateway on port ${PORT}..."
/usr/local/bin/falahos-gateway -w /usr/share/falahos/www 2>&1 | tee /var/log/falahos/gateway.log &
GW_PID=$!

# Wait for gateway to be fully up (writes management.url after handshake with message-bus)
wait_for_file /var/run/casaos/management.url gateway

# ── 3. UserService + Core (both need gateway management URL) ─────
log "starting user-service..."
/usr/local/bin/falahos-user-service 2>&1 | tee /var/log/falahos/user-service.log &
US_PID=$!

log "starting core..."
/usr/local/bin/falahos-core -c /etc/falahos/falahos.conf 2>&1 | tee /var/log/falahos/core.log &
CORE_PID=$!

# ── 4. AppManagement (skipped if no Docker socket) ───────────────
if [ -S /var/run/docker.sock ]; then
  log "starting app-management..."
  /usr/local/bin/falahos-appmgmt -c /etc/falahos/app-management.conf 2>&1 | tee /var/log/falahos/appmgmt.log &
  APPMGMT_PID=$!
else
  log "no Docker socket — skipping app-management"
  APPMGMT_PID=""
fi

log "all services started — gateway on port ${PORT}"

wait $MB_PID $GW_PID $US_PID $CORE_PID ${APPMGMT_PID:-}
