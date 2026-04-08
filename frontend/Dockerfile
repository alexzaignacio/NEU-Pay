# ─────────────────────────────────────────────────────────
# NEU-Pay Frontend (Web) – Multi-stage Dockerfile
# Uses HTML renderer for optimal performance on all devices.
# ─────────────────────────────────────────────────────────

# ── Stage 1: Build Flutter Web ──
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

# Cache pub dependencies
COPY pubspec.yaml pubspec.lock* ./
RUN flutter pub get

# Copy source and build for web with HTML renderer
COPY . .
RUN flutter build web --release --web-renderer html --dart-define=FLUTTER_WEB_AUTO_DETECT=false

# ── Stage 2: Serve with Nginx ──
FROM nginx:1.27-alpine AS runtime

# Remove default config
RUN rm /etc/nginx/conf.d/default.conf

# Custom Nginx config optimised for Flutter SPAs
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy built Flutter web app
COPY --from=build /app/build/web /usr/share/nginx/html

# Security: run as non-root
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chmod -R 755 /usr/share/nginx/html

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
