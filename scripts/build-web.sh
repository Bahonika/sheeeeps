#!/usr/bin/env bash
# Build the web client, pointing it at your live server.
# Usage:  scripts/build-web.sh wss://pasture.example.com
#   (use ws://localhost:8080 for a local server during development)
set -euo pipefail

URL="${1:?usage: scripts/build-web.sh <server-url, e.g. wss://pasture.example.com>}"

flutter build web \
  --release \
  -t lib/main_pasture.dart \
  --dart-define=PASTURE_URL="$URL"

echo ""
echo "Built build/web  (server URL baked in: $URL)"
echo "Deploy the contents of build/web to Cloudflare Pages (see DEPLOY.md)."
