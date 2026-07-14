#!/usr/bin/env bash
# Deploy pedals-of-hope to kirkautomations.com/pedals-of-hope/
# Usage: ./deploy.sh
#
# Prereqs:
#   - ssh access to kirk-auto (aliased in ~/.ssh/config)
#   - sudo on the box
#
# What it does:
#   1. Packages the working tree (excluding .git, node_modules)
#   2. Ships it to kirk-auto and extracts to /var/www/kirkautomations/pedals-of-hope
#   3. Verifies the live site is serving

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
REMOTE_HOST="kirk-auto"
REMOTE_PATH="/var/www/kirkautomations/pedals-of-hope"
LIVE_URL="https://pedalsofhope.com/"
TMP_TAR="/tmp/pedals-of-hope-$$.tar.gz"

echo "==> Packaging site from $REPO_ROOT"
cd "$REPO_ROOT"
tar czf "$TMP_TAR" \
  --exclude='.git' \
  --exclude='node_modules' \
  --exclude='deploy.sh' \
  --exclude='*.md' \
  .
ls -lh "$TMP_TAR"

echo ""
echo "==> Shipping to $REMOTE_HOST"
scp "$TMP_TAR" "$REMOTE_HOST:$TMP_TAR"

echo ""
echo "==> Extracting on $REMOTE_HOST -> $REMOTE_PATH"
ssh "$REMOTE_HOST" bash -s <<REMOTE_EOF
  set -euo pipefail
  sudo mkdir -p "$REMOTE_PATH"
  # Preserve nothing — full replace so removed files disappear from prod
  sudo rm -rf "$REMOTE_PATH".new
  sudo mkdir -p "$REMOTE_PATH".new
  sudo tar xzf "$TMP_TAR" -C "$REMOTE_PATH".new
  # Atomic swap
  sudo rm -rf "$REMOTE_PATH".old
  sudo mv "$REMOTE_PATH" "$REMOTE_PATH".old
  sudo mv "$REMOTE_PATH".new "$REMOTE_PATH"
  sudo rm -rf "$REMOTE_PATH".old
  # Ownership
  if id caddy >/dev/null 2>&1; then
    sudo chown -R caddy:caddy "$REMOTE_PATH"
  else
    sudo chown -R michael:michael "$REMOTE_PATH"
  fi
  rm "$TMP_TAR"
  echo "Files on prod:"
  ls "$REMOTE_PATH" | head
REMOTE_EOF

rm "$TMP_TAR"

echo ""
echo "==> Verifying live site"
sleep 1
CODE=$(curl -sS -o /dev/null -w "%{http_code}" "$LIVE_URL")
if [ "$CODE" = "200" ]; then
  echo "✅ Live at $LIVE_URL (HTTP $CODE)"
else
  echo "❌ Live check failed: HTTP $CODE"
  exit 1
fi
