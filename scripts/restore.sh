#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SOURCE=${1:?usage: restore.sh PATH_TO_BACKUP}
[[ -f "$SOURCE/prometheus-data.tar.gz" && -f "$SOURCE/grafana-data.tar.gz" ]] || { echo "Backup archives not found." >&2; exit 1; }
docker compose -f "$ROOT/observability/compose.yaml" down
docker volume create home-climate-observability_prometheus-data >/dev/null
docker volume create home-climate-observability_grafana-data >/dev/null
docker run --rm -v home-climate-observability_prometheus-data:/data -v "$SOURCE:/backup:ro" alpine:3.22 sh -c 'rm -rf /data/* && tar -xzf /backup/prometheus-data.tar.gz -C /data'
docker run --rm -v home-climate-observability_grafana-data:/data -v "$SOURCE:/backup:ro" alpine:3.22 sh -c 'rm -rf /data/* && tar -xzf /backup/grafana-data.tar.gz -C /data'
echo "Data volumes restored. Restore configuration.tar.gz manually after reviewing its contents, then start the stack."
