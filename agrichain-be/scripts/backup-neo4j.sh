#!/usr/bin/env bash
set -euo pipefail

D=$(date +%F)
OUT="/opt/agrichain/backups/neo4j/$D"
mkdir -p "$OUT"

docker exec smartchain-neo4j neo4j-admin database dump neo4j --to-stdout \
  | gzip > "$OUT/graph-$D.dump.gz"

rclone copy "$OUT" "agrichain-r2:agrichain-assets/backups/neo4j/$D/"
rclone delete --min-age 90d agrichain-r2:agrichain-assets/backups/neo4j
find /opt/agrichain/backups/neo4j -maxdepth 1 -mtime +7 -exec rm -rf {} +
