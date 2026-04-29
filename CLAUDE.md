# Falah OS — Project Memory

## What This Is
Falah OS Community Edition: rebranded CasaOS running in a single Docker container,
deployable to any Linux host or Google Cloud Run.

Four Go services start in dependency order:
```
MessageBus → Gateway → Core
                    → AppManagement
```
Pre-built Vue.js UI lives in `falah-os-workspace/dist/`.
The gateway proxies all traffic and serves the UI.

---

## CRITICAL: Runtime Path Invariants

`CasaOS-Common` (upstream dependency, not in this repo) hardcodes three paths:

| Constant | Value |
|---|---|
| `DefaultConfigPath` | `/etc/casaos` |
| `DefaultRuntimePath` | `/var/run/casaos` |
| `DefaultDataPath` | `/var/lib/casaos` |

**Rules that must never be violated:**

1. **Gateway config must be at `/etc/casaos/gateway.ini`** — the gateway binary has no `-c` flag. It always reads from `DefaultConfigPath`. Putting config at `/etc/falahos/gateway.ini` is silently ignored.

2. **All four services must share `/var/run/casaos` as `RuntimePath`** — inter-service coordination files (`message-bus.url`, `management.url`) are written and read from this directory. If services disagree on the path, they cannot find each other and the startup chain deadlocks.

3. **Data paths (`/var/lib/falahos/...`) are fine to use** — Core and AppManagement accept a `-c` flag that overrides the default data path. Logs, DB, apps, and UI can live under `/var/lib/falahos`.

---

## CRITICAL: Go Identifier Rules

A blanket `sed` rename changed `CasaOS` → `Falah OS` across all source. This broke Go:
- `type Falah OS struct` — invalid (space in identifier)
- `func NewFalah OS()` — invalid
- `codegen.ByCasaos` — renamed to `ByFalahos` in codegen but callers weren't updated

**Current state:** all fixed. Rules going forward:
- New Go identifiers use `FalahOS` (no space), not `Falah OS`
- If editing codegen output, check all callers in the same pass
- **Before every commit touching `.go` files**, run `go build ./...` in each affected module

---

## Build Verification (mandatory before any Go commit)

```bash
cd falah-os-workspace/CasaOS            && go build ./...
cd falah-os-workspace/CasaOS-AppManagement && go build ./...
cd falah-os-workspace/CasaOS-Gateway    && go build ./...
```

All three must pass with no output. If any fails, fix before committing.

---

## Architecture: File Layout

```
falah-os-workspace/
├── Dockerfile              # Multi-stage Go build; entrypoint.sh replaces supervisord
├── entrypoint.sh           # Injects $PORT → /etc/casaos/gateway.ini; starts services
├── docker-compose.yml      # Maps host:80 → container:8080 via PORT=8080
├── deploy-cloudrun.sh      # One-command: gcloud builds submit + gcloud run deploy
├── install.sh              # End-user installer (git clone + docker compose up)
├── dist/                   # Pre-built Vue.js UI (served by gateway via -w flag)
├── config/
│   ├── gateway.ini         # → /etc/casaos/gateway.ini  (RuntimePath=/var/run/casaos)
│   ├── falahos.conf        # → /etc/falahos/falahos.conf (Core reads via -c)
│   └── app-management.conf # → /etc/falahos/app-management.conf (AppMgmt reads via -c)
├── CasaOS/                 # Core service source
├── CasaOS-Gateway/         # Gateway source
├── CasaOS-AppManagement/   # AppManagement source
└── CasaOS-UI/              # UI source (built output goes to dist/)
```

---

## Container Startup Sequence

```
entrypoint.sh
  sed -i "s/^port=.*/port=${PORT}/" /etc/casaos/gateway.ini
  falahos-message-bus &              # waits for /var/run/casaos/message-bus.url
  falahos-gateway -w /var/lib/falahos/www &   # waits for /var/run/casaos/management.url
  falahos-core -c /etc/falahos/falahos.conf &
  falahos-appmgmt -c /etc/falahos/app-management.conf &  # skipped if no docker.sock
```

AppManagement silently skips when `/var/run/docker.sock` is absent (Cloud Run).

---

## Deployment

**Local / VPS:**
```bash
curl -fsSL https://raw.githubusercontent.com/maiforslab/digitalpro/<branch>/falah-os-workspace/install.sh | bash
# UI at http://<host>
```

**Google Cloud Run:**
```bash
cd falah-os-workspace
bash deploy-cloudrun.sh <GCP_PROJECT_ID> [REGION]
# Builds image, deploys, prints live URL
```

---

## Active Branch
`master` — PR #13 merged. `install.sh` correctly clones `master`.

---

## go:generate Note
Both `CasaOS/main.go` and `CasaOS-AppManagement/main.go` have `//go:generate` directives
that fetch the MessageBus OpenAPI spec. URL must be:
`https://raw.githubusercontent.com/IceWhaleTech/CasaOS-MessageBus/main/api/message_bus/openapi.yaml`
(not `Falah OS-MessageBus` — that URL doesn't exist).
Codegen output is pre-committed; `go generate` only needed when updating the OpenAPI spec.
