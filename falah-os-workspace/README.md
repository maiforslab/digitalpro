# Falah OS Community Edition v1.0

> **The Sovereign Digital Economy in a Box.**
> Forked from the incredible [CasaOS](https://github.com/IceWhaleTech/CasaOS) open-source project by IceWhale Technology.

---

## What is Falah OS?

Falah OS is a sovereign, Docker-based cloud operating system for the global Muslim Ummah. It empowers individuals, families, and communities to run their own private digital infrastructure — free from centralized Big Tech dependency.

## Design Language: Islamic Sovereign Premium

| Element        | Value                     |
|----------------|---------------------------|
| Primary Accent | Emerald Green `#10b981`   |
| Secondary      | Teal `#0d9488`            |
| Background     | Slate-900 `#0f172a`       |
| Deep BG        | Slate-950 `#020617`       |
| UI Style       | Glassmorphism (backdrop-blur, frosted glass) |

## Repository Structure

```
falah-os-workspace/
├── CasaOS/                   # Core API daemon (Go)
├── CasaOS-Gateway/           # API gateway & reverse proxy (Go)
├── CasaOS-AppManagement/     # iStore & app lifecycle manager (Go)
├── CasaOS-UI/                # Falah OS Dashboard (Vue.js)
├── build-falah.sh            # Build all components
└── docker-compose.yml        # Local dev/test environment
```

## Quick Start

### Option A: Docker Compose (Recommended)

```bash
# 1. Clone this repo
git clone <falah-os-repo-url>
cd falah-os-workspace

# 2. Start all services
docker compose up -d

# 3. Open the dashboard
open http://localhost:3000
```

### Option B: Build from Source

```bash
# Requirements: Go 1.21+, Node.js 18+, npm 9+

# Build everything
./build-falah.sh

# Run the dashboard dev server
cd CasaOS-UI
npm install --legacy-peer-deps
npm run serve
```

## Key Changes from CasaOS

| CasaOS           | Falah OS                    |
|------------------|-----------------------------|
| CasaOS           | Falah OS                    |
| App Store        | iStore                      |
| CasaOS Team      | Falah Core Contributors     |
| Blue theme       | Emerald Green `#10b981`     |
| Light mode       | Deep Slate dark mode        |
| IceWhale registry| `api.falah-consultancy.ltd` |
| "System Status"  | "Sovereign Node Status"     |
| "Network Status" | "Global Network Link"       |

## iStore Registry

The iStore connects to: `https://api.falah-consultancy.ltd/istore/apps.json`

Categories:
- **Discover** — Featured sovereign apps
- **Finance (Muamalat)** — Halal-compliant finance tools
- **Productivity** — Self-hosted productivity suite
- **Security** — Privacy & encryption tools
- **Sovereign Nodes** — Blockchain & decentralized infrastructure

## Credits

This project is a community fork of [CasaOS](https://github.com/IceWhaleTech/CasaOS) by IceWhale Technology. All original engineering work is credited to the CasaOS contributors. Licensed under Apache 2.0.

---

*Falah OS — Striving for digital sovereignty, one node at a time.*
