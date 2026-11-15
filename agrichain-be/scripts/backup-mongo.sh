#!/usr/bin/env bash
set -euo pipefail

ENV_FILE="/opt/agrichain/backend/.env"
if [ -f "$ENV_FILE" ]; then
  set -a
  # shellcheck disable=SC1090
  source "$ENV_FILE"
  set +a
fi

D=$(date +%F)
OUT="/opt/agrichain/backups/mongo/$D"
mkdir -p "$OUT"

docker exec smartchain-mongodb mongodump -u mongoadmin -p "$MONGO_PASSWORD" \
  --authenticationDatabase admin -d supermarket_mongo --archive --gzip > "$OUT/dump.agz"

docker exec smartchain-mongodb mongoexport -u mongoadmin -p "$MONGO_PASSWORD" \
  --authenticationDatabase admin -d supermarket_mongo -c food_batches \
  --jsonArray -o "$OUT/food_batches.json"

docker exec smartchain-mongodb mongoexport -u mongoadmin -p "$MONGO_PASSWORD" \
  --authenticationDatabase admin -d supermarket_mongo -c blockchain_ledger \
  --jsonArray -o "$OUT/blockchain_ledger.json"

rclone copy "$OUT" "agrichain-r2:agrichain-assets/backups/mongo/$D" --transfers 8
rclone delete --min-age 90d agrichain-r2:agrichain-assets/backups/mongo
find /opt/agrichain/backups/mongo -maxdepth 1 -mtime +7 -exec rm -rf {} +
