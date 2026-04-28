#!/usr/bin/env bash
set -euo pipefail

REPO="https://github.com/maiforslab/digitalpro.git"
BRANCH="master"
WORK_DIR="/tmp/falahos-$$"
CONTAINER_NAME="falahos"
PORT="${PORT:-8088}"

printf '\n'
printf '  ███████╗ █████╗ ██╗      █████╗ ██╗  ██╗     ██████╗ ███████╗\n'
printf '  ██╔════╝██╔══██╗██║     ██╔══██╗██║  ██║    ██╔═══██╗██╔════╝\n'
printf '  █████╗  ███████║██║     ███████║███████║    ██║   ██║███████╗\n'
printf '  ██╔══╝  ██╔══██║██║     ██╔══██║██╔══██║    ██║   ██║╚════██║\n'
printf '  ██║     ██║  ██║███████╗██║  ██║██║  ██║    ╚██████╔╝███████║\n'
printf '  ╚═╝     ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝     ╚═════╝ ╚══════╝\n'
printf '\n'
printf '  Falah OS Community Edition — One-Line Installer\n'
printf '\n'

# --- Preflight checks ---
if ! command -v docker &>/dev/null; then
  printf 'Error: Docker is not installed.\n'
  printf 'Install it first: https://docs.docker.com/get-docker/\n'
  exit 1
fi

if ! command -v git &>/dev/null; then
  printf 'Error: git is not installed.\n'
  exit 1
fi

printf '[1/4] Downloading Falah OS (shallow clone)...\n'
git clone --depth 1 --branch "$BRANCH" "$REPO" "$WORK_DIR" --quiet

printf '[2/4] Building Docker image...\n'
docker build -t falahos "$WORK_DIR/falah-os-workspace" --quiet

printf '[3/4] Removing any existing Falah OS container...\n'
docker rm -f "$CONTAINER_NAME" 2>/dev/null || true

printf '[4/4] Starting Falah OS on port %s...\n' "$PORT"
docker run -d \
  --name "$CONTAINER_NAME" \
  -p "${PORT}:80" \
  --restart unless-stopped \
  falahos

rm -rf "$WORK_DIR"

IP=$(hostname -I 2>/dev/null | awk '{print $1}') || IP="your-server-ip"

printf '\n'
printf '  ✓ Falah OS is live at:  http://%s:%s\n' "$IP" "$PORT"
printf '\n'
printf '  To stop:    docker stop falahos\n'
printf '  To restart: docker start falahos\n'
printf '  To update:  curl -fsSL https://raw.githubusercontent.com/maiforslab/digitalpro/master/falah-os-workspace/install.sh | bash\n'
printf '\n'
