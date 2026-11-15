#!/usr/bin/env bash
set -euo pipefail

YM=$(date +%Y-%m)
D=$(date +%F)
OUT="/opt/agrichain/backups/cassandra/$D"
mkdir -p "$OUT"

docker exec smartchain-cassandra cqlsh -e "
  COPY supermarket_telemetry_ks.sensor_telemetry
  (batch_code, year_month, recorded_at, device_id, category, temperature, humidity,
   gas_value, gas_type, weight_kg, door_open, is_breached)
  TO '/tmp/telemetry-$YM.csv' WITH HEADER = TRUE AND MAXREQUESTS = 8;"

docker exec smartchain-cassandra cat "/tmp/telemetry-$YM.csv" | gzip > "$OUT/sensor_telemetry-$YM.csv.gz"
rclone copy "$OUT" "agrichain-r2:agrichain-assets/backups/cassandra/$D/"
rclone delete --min-age 90d agrichain-r2:agrichain-assets/backups/cassandra
find /opt/agrichain/backups/cassandra -maxdepth 1 -mtime +7 -exec rm -rf {} +
