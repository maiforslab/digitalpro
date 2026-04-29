#!/usr/bin/env bash
set -euo pipefail

REPO="https://github.com/maiforslab/digitalpro.git"
BRANCH="claude/falah-os-v1-build-dmw7p"
INSTALL_DIR="${HOME:-$PWD}/falahos"
CONTAINER_NAME="falahos"

# ── Colours ──────────────────────────────────────────────────────
GREEN='\033[0;32m'; CYAN='\033[0;36m'; YELLOW='\033[1;33m'
BOLD='\033[1m'; RESET='\033[0m'

# ── Spinner ───────────────────────────────────────────────────────
spinner_pid=""
spinner_start() {
  local msg="$1"
  local frames='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
  printf "${CYAN}"
  while true; do
    for i in $(seq 0 9); do
      printf "\r  ${frames:$i:1}  %s" "$msg"
      sleep 0.1
    done
  done &
  spinner_pid=$!
}
spinner_stop() {
  if [ -n "$spinner_pid" ]; then
    kill "$spinner_pid" 2>/dev/null || true
    wait "$spinner_pid" 2>/dev/null || true
    spinner_pid=""
  fi
  printf "\r${GREEN}  ✓${RESET}  %s\n" "$1"
}

# ── Step banner ───────────────────────────────────────────────────
step() { printf "\n${BOLD}${CYAN}[%s/4]${RESET} %s\n" "$1" "$2"; }

printf '\n'
printf "${GREEN}"
printf '  ███████╗ █████╗ ██╗      █████╗ ██╗  ██╗     ██████╗ ███████╗\n'
printf '  ██╔════╝██╔══██╗██║     ██╔══██╗██║  ██║    ██╔═══██╗██╔════╝\n'
printf '  █████╗  ███████║██║     ███████║███████║    ██║   ██║███████╗\n'
printf '  ██╔══╝  ██╔══██║██║     ██╔══██║██╔══██║    ██║   ██║╚════██║\n'
printf '  ██║     ██║  ██║███████╗██║  ██║██║  ██║    ╚██████╔╝███████║\n'
printf '  ╚═╝     ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝     ╚═════╝ ╚══════╝\n'
printf "${RESET}\n"
printf "  ${BOLD}Falah OS Community Edition — Installer${RESET}\n\n"

# ── Preflight ────────────────────────────────────────────────────
if ! command -v docker &>/dev/null; then
  printf "${YELLOW}Error:${RESET} Docker is not installed.\n"
  printf "Install it: https://docs.docker.com/get-docker/\n"
  exit 1
fi
if ! command -v git &>/dev/null; then
  printf "${YELLOW}Error:${RESET} git is not installed.\n"
  exit 1
fi

# ── Step 1: Download ─────────────────────────────────────────────
step 1 "Downloading Falah OS source..."
if [ -d "$INSTALL_DIR/.git" ]; then
  spinner_start "Updating existing installation..."
  git -C "$INSTALL_DIR" pull origin "$BRANCH" --quiet 2>&1
  spinner_stop "Source updated"
else
  rm -rf "$INSTALL_DIR"
  spinner_start "Cloning repository..."
  git clone --depth 1 --branch "$BRANCH" "$REPO" "$INSTALL_DIR" --progress 2>&1 | \
    grep -E "^Cloning|objects:|Receiving|Resolving|remote:" | \
    while IFS= read -r line; do printf "\r  ${CYAN}%-70s${RESET}" "$line"; done || true
  spinner_stop "Source downloaded to $INSTALL_DIR"
fi

cd "$INSTALL_DIR/falah-os-workspace"

# ── Step 2: Build ────────────────────────────────────────────────
step 2 "Building Docker image — compiling all services (~5 min first run)"
printf "  ${CYAN}Docker build progress:${RESET}\n\n"
docker compose build --progress=plain 2>&1 | \
  grep -E "^#|Step|STEP|--->" | \
  while IFS= read -r line; do printf "  ${CYAN}│${RESET} %s\n" "$line"; done || \
  docker compose build 2>&1
printf "\n  ${GREEN}✓${RESET}  Image built\n"

# ── Step 3: Stop old container ───────────────────────────────────
step 3 "Stopping any existing container..."
spinner_start "Removing old container..."
docker compose down 2>/dev/null || true
spinner_stop "Old container removed"

# ── Step 4: Start ────────────────────────────────────────────────
step 4 "Starting all Falah OS services..."
docker compose up -d
printf "  ${GREEN}✓${RESET}  All services started\n"

# ── Done ─────────────────────────────────────────────────────────
IP=$(hostname -I 2>/dev/null | awk '{print $1}') || IP="your-server-ip"

printf "\n"
printf "  ${BOLD}${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"
printf "  ${BOLD}${GREEN}  Falah OS is live at:  http://%s${RESET}\n" "$IP"
printf "  ${BOLD}${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"
printf "\n"
printf "  Logs:    ${CYAN}docker logs -f falahos${RESET}\n"
printf "  Stop:    ${CYAN}cd %s && docker compose down${RESET}\n" "$INSTALL_DIR/falah-os-workspace"
printf "  Update:  ${CYAN}curl -fsSL https://raw.githubusercontent.com/maiforslab/digitalpro/claude/falah-os-v1-build-dmw7p/falah-os-workspace/install.sh | bash${RESET}\n"
printf "\n"
