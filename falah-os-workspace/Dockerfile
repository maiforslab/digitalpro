# Falah OS Community Edition v1.0
# Multi-stage: builds Vue.js dashboard then serves via nginx

# ── Stage 1: Build ────────────────────────────────────────────
FROM node:18-alpine AS builder

WORKDIR /app

# Copy package files first for layer caching
COPY CasaOS-UI/package.json CasaOS-UI/package-lock.json ./

# Install dependencies
RUN npm install --legacy-peer-deps

# Copy full UI source
COPY CasaOS-UI/ ./

# Build production bundle
RUN npm run build

# ── Stage 2: Serve ────────────────────────────────────────────
FROM nginx:alpine

# Remove default nginx content
RUN rm -rf /usr/share/nginx/html/*

# Copy built dashboard from builder stage
COPY --from=builder /app/build/sysroot/var/lib/falahos/www/ /usr/share/nginx/html/

# SPA nginx config — all routes fall back to index.html
RUN printf '\
server {\n\
    listen 80;\n\
    server_name _;\n\
    root /usr/share/nginx/html;\n\
    index index.html;\n\
    gzip on;\n\
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml image/svg+xml;\n\
    location / {\n\
        try_files $uri $uri/ /index.html;\n\
    }\n\
    location ~* \\.(js|css|png|svg|ico|woff|woff2|ttf|eot)$ {\n\
        expires 1y;\n\
        add_header Cache-Control "public, immutable";\n\
    }\n\
}\n' > /etc/nginx/conf.d/default.conf

EXPOSE 80

LABEL org.opencontainers.image.title="Falah OS Community Edition" \
      org.opencontainers.image.description="The Sovereign Digital Economy in a Box — forked from CasaOS" \
      org.opencontainers.image.version="1.0.0"
