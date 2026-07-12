#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$ROOT"
command -v docker >/dev/null || { echo "Docker is required." >&2; exit 1; }
docker compose version >/dev/null

[[ -f .env ]] || cp .env.example .env
mkdir -p secrets
if [[ ! -f secrets/grafana_admin_password ]]; then
  if command -v openssl >/dev/null; then
    openssl rand -base64 36 > secrets/grafana_admin_password
  else
    echo "Generate a strong password and save it here." > secrets/grafana_admin_password
  fi
fi
if [[ ! -f secrets/home_assistant_token ]]; then
  : > secrets/home_assistant_token
  echo "Home Assistant token file created empty. Complete onboarding, create a dedicated long-lived token, then paste it into secrets/home_assistant_token."
fi
chmod 600 secrets/grafana_admin_password secrets/home_assistant_token
echo "Bootstrap complete. Review .env and docs/entity-mapping.md before starting automation."
