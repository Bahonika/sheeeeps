# ── Build stage ──────────────────────────────────────────────────────────────
# The pasture server reuses the game's Dart simulation, so it lives in a Flutter
# package. `dart compile exe` only pulls the reachable graph (Domain/Data/Shared —
# no Flutter/dart:ui), producing a self-contained native binary. We still need the
# Flutter SDK present so `flutter pub get` can resolve the flutter dependency.
FROM ghcr.io/cirruslabs/flutter:stable AS build
WORKDIR /app

# Resolve dependencies first for better layer caching.
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Then the sources and compile the headless server to a native executable.
COPY . .
RUN dart compile exe bin/server.dart -o /app/pasture-server

# ── Runtime stage ────────────────────────────────────────────────────────────
# The compiled binary embeds the Dart runtime; it only needs libc + CA certs.
FROM debian:bookworm-slim
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates \
    && rm -rf /var/lib/apt/lists/*
COPY --from=build /app/pasture-server /usr/local/bin/pasture-server

# The server binds $PORT (default 8080). Hosts that inject their own PORT (Koyeb,
# Render, Cloud Run) just work; locally it defaults to 8080.
ENV PORT=8080
EXPOSE 8080

# Simple liveness probe target: GET /health → 200 "ok".
CMD ["pasture-server"]
