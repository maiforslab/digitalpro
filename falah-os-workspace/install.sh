#!/usr/bin/env bash
set -euo pipefail

# Require root (sudo)
if [ "$(id -u)" -ne 0 ]; then
  printf 'Error: run with sudo:\n'
  printf '  curl -fsSL https://raw.githubusercontent.com/maiforslab/digitalpro/master/falah-os-workspace/install.sh | sudo bash\n'
  exit 1
fi

REPO="https://github.com/maiforslab/digitalpro.git"
BRANCH="master"
INSTALL_DIR="/opt/falahos"
CONTAINER_NAME="falahos"

printf '\n'
printf '  ███████╗ █████╗ ██╗      █████╗ ██╗  ██╗     ██████╗ ███████╗\n'
printf '  ██╔════╝██╔══██╗██║     ██╔══██╗██║  ██║    ██╔═══██╗██╔════╝\n'
printf '  █████╗  ███████║██║     ███████║███████║    ██║   ██║███████╗\n'
printf '  ██╔══╝  ██╔══██║██║     ██╔══██║██╔══██║    ██║   ██║╚════██║\n'
printf '  ██║     ██║  ██║███████╗██║  ██║██║  ██║    ╚██████╔╝███████║\n'
printf '  ╚═╝     ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝     ╚═════╝ ╚══════╝\n'
printf '\n'
printf '  Falah OS Community Edition — Installer\n'
printf '\n'

# --- Preflight checks ---
if ! command -v docker &>/dev/null; then
  printf 'Error: Docker is not installed.\n'
  printf 'Install it: https://docs.docker.com/get-docker/\n'
  exit 1
fi

if ! command -v git &>/dev/null; then
  printf 'Error: git is not installed.\n'
  exit 1
fi

printf '[1/4] Downloading Falah OS...\n'
if [ -d "$INSTALL_DIR/.git" ]; then
  git -C "$INSTALL_DIR" pull origin "$BRANCH" --quiet
else
  rm -rf "$INSTALL_DIR"
  git clone --depth 1 --branch "$BRANCH" "$REPO" "$INSTALL_DIR" --quiet
fi

cd "$INSTALL_DIR/falah-os-workspace"

printf '[2/4] Building Docker image (this takes ~5 min on first run)...\n'
docker compose build --quiet

printf '[3/4] Stopping any existing Falah OS container...\n'
docker compose down 2>/dev/null || true

printf '[4/4] Starting all Falah OS services...\n'
docker compose up -d

IP=$(hostname -I 2>/dev/null | awk '{print $1}') || IP="your-server-ip"

printf '\n'
printf '  ✓ Falah OS is live at:  http://%s\n' "$IP"
printf '\n'
printf '  Logs:    docker logs -f falahos\n'
printf '  Stop:    cd %s && docker compose down\n' "$INSTALL_DIR/falah-os-workspace"
printf '  Update:  curl -fsSL https://raw.githubusercontent.com/maiforslab/digitalpro/master/falah-os-workspace/install.sh | sudo bash\n'
printf '\n'
