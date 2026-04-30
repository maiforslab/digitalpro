# ════════════════════════════════════════════════════════════════
#  Falah OS Community Edition — Production Image
#  Cloud Run compatible: listens on $PORT (default 8080)
#  Local:               docker compose up -d  (port 80 or 8080)
# ════════════════════════════════════════════════════════════════

# ── Stage 1: Build all Go services ──────────────────────────────
FROM golang:1.21-alpine AS go-builder

RUN apk add --no-cache git gcc musl-dev

WORKDIR /src

# MessageBus — swap modernc.org/sqlite (pure-Go, broken on some kernels) for
# mattn/go-sqlite3 (real C SQLite, requires CGO; gcc+musl-dev already installed)
RUN git clone --depth 1 https://github.com/IceWhaleTech/CasaOS-MessageBus.git && \
    cd CasaOS-MessageBus && \
    grep -rl "github.com/glebarez/sqlite" --include="*.go" . | \
        xargs sed -i 's|github.com/glebarez/sqlite|gorm.io/driver/sqlite|g' && \
    go get gorm.io/driver/sqlite@latest && \
    go mod tidy && \
    go build -ldflags="-s -w" -o /out/message-bus .

# Gateway
COPY CasaOS-Gateway/go.mod CasaOS-Gateway/go.sum ./CasaOS-Gateway/
RUN cd CasaOS-Gateway && go mod download
COPY CasaOS-Gateway/ ./CasaOS-Gateway/
RUN cd CasaOS-Gateway && CGO_ENABLED=0 go build -ldflags="-s -w" -o /out/gateway .

# Core
COPY CasaOS/go.mod CasaOS/go.sum ./CasaOS/
RUN cd CasaOS && go mod download
COPY CasaOS/ ./CasaOS/
RUN cd CasaOS && CGO_ENABLED=0 go build -ldflags="-s -w" -o /out/core .

# AppManagement
COPY CasaOS-AppManagement/go.mod CasaOS-AppManagement/go.sum ./CasaOS-AppManagement/
RUN cd CasaOS-AppManagement && go mod download
COPY CasaOS-AppManagement/ ./CasaOS-AppManagement/
RUN cd CasaOS-AppManagement && CGO_ENABLED=0 go build -ldflags="-s -w" -o /out/appmgmt .

# ── Stage 2: Runtime image ───────────────────────────────────────
FROM alpine:3.18

RUN apk add --no-cache ca-certificates bash tzdata

# Copy compiled binaries
COPY --from=go-builder /out/message-bus  /usr/local/bin/falahos-message-bus
COPY --from=go-builder /out/gateway      /usr/local/bin/falahos-gateway
COPY --from=go-builder /out/core         /usr/local/bin/falahos-core
COPY --from=go-builder /out/appmgmt      /usr/local/bin/falahos-appmgmt

# Runtime coordination path (must match CasaOS-Common constants — services find
# each other's .url files here; not user-visible so keeping upstream path)
RUN mkdir -p \
    /var/run/casaos \
    /etc/casaos \
    /var/lib/casaos \
    /var/lib/falahos/www \
    /var/lib/falahos/db \
    /var/lib/falahos/apps \
    /var/lib/falahos/istore \
    /var/lib/falahos/conf \
    /var/log/falahos \
    /etc/falahos \
    /usr/share/falahos/shell

# Pre-built Falah OS frontend
COPY dist/ /var/lib/falahos/www/

# Gateway reads config from DefaultConfigPath (/etc/casaos) — no -c flag support
COPY config/gateway.ini           /etc/casaos/gateway.ini
# Core and AppManagement read config via -c flag (paths in entrypoint.sh)
COPY config/falahos.conf          /etc/falahos/falahos.conf
COPY config/app-management.conf   /etc/falahos/app-management.conf

# Entrypoint (Cloud Run compatible — injects $PORT, starts services in order)
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENV PORT=8080
EXPOSE 8080

CMD ["/entrypoint.sh"]
