#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TOKEN_FILE=${HA_TOKEN_FILE:-$ROOT/secrets/home_assistant_token}
URL=${HA_METRICS_URL:-http://127.0.0.1:8123/api/prometheus}
PROMETHEUS_URL=${PROMETHEUS_URL:-http://127.0.0.1:9090}
[[ -s "$TOKEN_FILE" ]] || { echo "Home Assistant token file is missing or empty." >&2; exit 1; }
tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT
status=$(curl --silent --show-error --output "$tmp" --write-out '%{http_code}' \
  --connect-timeout 5 --max-time 30 -H "Authorization: Bearer $(<"$TOKEN_FILE")" "$URL") || {
  echo "Could not connect to Home Assistant metrics endpoint." >&2; exit 1;
}
[[ "$status" != 401 ]] || { echo "Home Assistant rejected the token (HTTP 401)." >&2; exit 1; }
[[ "$status" == 200 ]] || { echo "Home Assistant returned HTTP $status." >&2; exit 1; }
required_exported_metrics=(
  'hass_sensor_temperature_celsius.*entity="sensor.climate_indoor_temperature"'
  'hass_sensor_humidity_percent.*entity="sensor.climate_indoor_humidity"'
  'hass_sensor_temperature_celsius.*entity="sensor.climate_outdoor_temperature"'
  'hass_sensor_humidity_percent.*entity="sensor.climate_outdoor_humidity"'
)
for pattern in "${required_exported_metrics[@]}"; do
  grep -Eq "^${pattern}" "$tmp" || {
    echo "Missing expected Home Assistant metric matching: $pattern" >&2
    exit 1
  }
done

required_prometheus_series=(
  'up{job="home-assistant"} == 1'
  'climate:indoor_temperature_celsius'
  'climate:indoor_humidity_percent'
  'climate:outdoor_temperature_celsius'
  'climate:outdoor_humidity_percent'
)
for query in "${required_prometheus_series[@]}"; do
  response=$(curl --silent --show-error --get --max-time 15 \
    --data-urlencode "query=$query" "$PROMETHEUS_URL/api/v1/query") || {
    echo "Could not query Prometheus at $PROMETHEUS_URL." >&2
    exit 1
  }
  jq -e '.status == "success" and (.data.result | length > 0)' <<<"$response" >/dev/null || {
    echo "Prometheus returned no data for: $query" >&2
    exit 1
  }
done

echo "Live climate metrics are available in Home Assistant and Prometheus."
