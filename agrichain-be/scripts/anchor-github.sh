#!/usr/bin/env bash
set -euo pipefail

ENV_FILE="/opt/agrichain/backend/.env"
if [ -f "$ENV_FILE" ]; then
  set -a
  # shellcheck disable=SC1090
  source "$ENV_FILE"
  set +a
fi

D=$(date -u -d "yesterday" +%F 2>/dev/null || date -u +%F)
ANCHOR_REPO="${ANCHOR_REPO_DIR:-/opt/agrichain/anchor-repo}"

HASHES=$(docker exec smartchain-mongodb mongosh --quiet \
  -u mongoadmin -p "$MONGO_PASSWORD" --authenticationDatabase admin supermarket_mongo \
  --eval "db.blockchain_ledger.find({ timestamp: { \$regex: '^${D}' } }, { current_hash: 1, _id: 0 }).sort({ current_hash: 1 }).map(d => d.current_hash).toArray().join('\n')")

DAY_ROOT=$(printf '%s' "$HASHES" | sha256sum | awk '{print $1}')

if [ -d "$ANCHOR_REPO/.git" ]; then
  mkdir -p "$ANCHOR_REPO/anchors"
  {
    echo "date=$D"
    echo "day_root=$DAY_ROOT"
    echo "count=$(printf '%s\n' "$HASHES" | grep -c . || true)"
  } > "$ANCHOR_REPO/anchors/$D.txt"
  git -C "$ANCHOR_REPO" add "anchors/$D.txt"
  if ! git -C "$ANCHOR_REPO" diff --cached --quiet; then
    git -C "$ANCHOR_REPO" commit -m "anchor: $D ($DAY_ROOT)"
    git -C "$ANCHOR_REPO" push origin main
  fi
else
  echo "[$D] day_root=$DAY_ROOT (anchor repo not initialized at $ANCHOR_REPO)"
fi
