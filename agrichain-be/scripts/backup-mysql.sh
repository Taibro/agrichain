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
OUT="/opt/agrichain/backups/mysql/$D"
mkdir -p "$OUT"

docker exec smartchain-mysql sh -c 'exec mysqldump --single-transaction --routines --triggers -u root -p"$MYSQL_ROOT_PASSWORD" supermarket_db' \
  | gzip > "$OUT/supermarket_db-$D.sql.gz"

rclone copy "$OUT" "agrichain-r2:agrichain-assets/backups/mysql/$D/"
rclone delete --min-age 90d agrichain-r2:agrichain-assets/backups/mysql
find /opt/agrichain/backups/mysql -maxdepth 1 -mtime +7 -exec rm -rf {} +
