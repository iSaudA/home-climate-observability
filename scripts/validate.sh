#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$ROOT"
export HOST_IP=${HOST_IP:-192.0.2.1}
export GRAFANA_BIND_ADDRESS=${GRAFANA_BIND_ADDRESS:-127.0.0.1}

cleanup=()
for name in home_assistant_token grafana_admin_password; do
  if [[ ! -f "secrets/$name" ]]; then
    printf 'validation-placeholder\n' > "secrets/$name"
    chmod 600 "secrets/$name"
    cleanup+=("secrets/$name")
  fi
done
trap 'if ((${#cleanup[@]})); then rm -f "${cleanup[@]}"; fi' EXIT

docker compose -f home-automation/compose.yaml config --quiet
docker compose -f observability/compose.yaml config --quiet
docker compose config --quiet

docker run --rm -v "$ROOT/observability/prometheus:/etc/prometheus:ro" \
  -v "$ROOT/secrets/home_assistant_token:/run/secrets/home_assistant_token:ro" \
  --entrypoint promtool prom/prometheus:v3.11.0 check config /etc/prometheus/prometheus.yml
docker run --rm -v "$ROOT/observability/prometheus/rules:/rules:ro" \
  --entrypoint promtool prom/prometheus:v3.11.0 check rules /rules/climate.yml /rules/infrastructure.yml

find observability/grafana/dashboards -name '*.json' -print0 | xargs -0 -n1 jq -e . >/dev/null
docker run --rm -v "$ROOT/observability/grafana/provisioning:/work:ro" mikefarah/yq:4.45.4 \
  eval-all 'true' /work/datasources/prometheus.yml /work/dashboards/dashboards.yml >/dev/null

if command -v shellcheck >/dev/null; then shellcheck scripts/*.sh; else echo "shellcheck not installed; skipping local shell lint"; fi
docker run --rm -v "$ROOT/home-automation/config:/config" ghcr.io/home-assistant/home-assistant:2026.5.4 python -m homeassistant --script check_config --config /config
echo "Validation passed. Hardware communication was not tested."
