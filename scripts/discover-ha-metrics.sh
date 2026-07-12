#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TOKEN_FILE=${HA_TOKEN_FILE:-$ROOT/secrets/home_assistant_token}
URL=${HA_METRICS_URL:-http://127.0.0.1:8123/api/prometheus}
[[ -s "$TOKEN_FILE" ]] || { echo "Home Assistant token file is missing or empty." >&2; exit 1; }
tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT
status=$(curl --silent --show-error --output "$tmp" --write-out '%{http_code}' \
  --connect-timeout 5 --max-time 30 -H "Authorization: Bearer $(<"$TOKEN_FILE")" "$URL") || {
  echo "Could not connect to Home Assistant metrics endpoint." >&2; exit 1;
}
[[ "$status" != 401 ]] || { echo "Home Assistant rejected the token (HTTP 401)." >&2; exit 1; }
[[ "$status" == 200 ]] || { echo "Home Assistant returned HTTP $status." >&2; exit 1; }
results=$(grep -E '^(# (HELP|TYPE) )?hass_.*(climate_|ac_)' "$tmp" || true)
[[ -n "$results" ]] || { echo "No normalized climate metrics found; verify mappings and the Prometheus filter." >&2; exit 1; }
printf '%s\n' "$results" | sed -E 's/\{.*//' | sort -u
