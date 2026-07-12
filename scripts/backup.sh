#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
DEST=${1:-$ROOT/backups/$(date -u +%Y%m%dT%H%M%SZ)}
mkdir -p "$DEST"
tar --exclude='.storage' --exclude='home-assistant_v2.db*' --exclude='*.log*' -czf "$DEST/configuration.tar.gz" -C "$ROOT" home-automation/config observability .env.example
docker compose -f "$ROOT/observability/compose.yaml" stop prometheus grafana
trap 'docker compose -f "$ROOT/observability/compose.yaml" start prometheus grafana >/dev/null || true' EXIT
docker run --rm -v home-climate-observability_prometheus-data:/data:ro -v "$DEST:/backup" alpine:3.22 tar -czf /backup/prometheus-data.tar.gz -C /data .
docker run --rm -v home-climate-observability_grafana-data:/data:ro -v "$DEST:/backup" alpine:3.22 tar -czf /backup/grafana-data.tar.gz -C /data .
echo "Backup written to $DEST"
