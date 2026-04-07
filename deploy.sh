#!/usr/bin/env bash
# GNOrg deploy script
# Run this on the server whenever you want to deploy the latest code from main.
# Usage: ./deploy.sh

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

echo ""
echo "=== GNOrg Deploy ==="
echo ""

cd "$REPO_DIR"

echo "--- [1/4] Pulling latest code from main ---"
git pull origin main

echo ""
echo "--- [2/4] Installing backend dependencies ---"
npm install --omit=dev

echo ""
echo "--- [3/4] Installing frontend dependencies and building ---"
cd web
npm install
npm run build
cd ..

echo ""
echo "--- [4/4] Reloading backend (PM2) ---"
pm2 reload ecosystem.config.js --update-env

echo ""
echo "=== Deploy complete ==="
echo ""
