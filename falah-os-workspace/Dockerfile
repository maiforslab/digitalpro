# ════════════════════════════════════════════════════════════════
#  Falah OS Community Edition — Production Image
#  Services: MessageBus → Gateway → Core + AppManagement + UI
# ════════════════════════════════════════════════════════════════

# ── Stage 1: Build all Go services ──────────────────────────────
FROM golang:1.21-alpine AS go-builder

RUN apk add --no-cache git

WORKDIR /src

# MessageBus (cloned from upstream IceWhale)
RUN git clone --depth 1 https://github.com/IceWhaleTech/CasaOS-MessageBus.git && \
    cd CasaOS-MessageBus && \
    go mod download && \
    CGO_ENABLED=0 go build -ldflags="-s -w" -o /out/message-bus .

# Gateway — copy go.mod first for layer caching
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

RUN apk add --no-cache supervisor ca-certificates bash tzdata

# Copy compiled binaries
COPY --from=go-builder /out/message-bus  /usr/local/bin/falahos-message-bus
COPY --from=go-builder /out/gateway      /usr/local/bin/falahos-gateway
COPY --from=go-builder /out/core         /usr/local/bin/falahos-core
COPY --from=go-builder /out/appmgmt      /usr/local/bin/falahos-appmgmt

# Runtime and data directories
RUN mkdir -p \
    /var/run/casaos \
    /var/lib/casaos/www \
    /var/lib/casaos/db \
    /var/lib/casaos/apps \
    /var/lib/casaos/istore \
    /var/lib/casaos/conf \
    /var/log/casaos \
    /etc/casaos \
    /usr/share/casaos/shell

# Pre-built Falah OS frontend
COPY dist/ /var/lib/casaos/www/

# Service config files
COPY config/falahos.conf          /etc/casaos/falahos.conf
COPY config/gateway.ini           /etc/casaos/gateway.ini
COPY config/app-management.conf   /etc/casaos/app-management.conf

# Supervisord config
COPY supervisord.conf /etc/supervisord.conf

EXPOSE 80

CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"]
