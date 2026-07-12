# Observability

Prometheus scrapes every 30 seconds and retains up to 90 days or 10 GB by default. Recording rules translate current Home Assistant exporter series into stable `climate:*` names. After entities exist, run `scripts/discover-ha-metrics.sh`; if an exporter version changes a metric family, compare its authenticated output to `rules/climate.yml` and update the recording selector—not every dashboard.

Setup-sensitive climate alerts depend on exported entities and some additionally require automation to be enabled. During onboarding, silence the climate alert group in Prometheus or temporarily move `climate.yml` out of the loaded rules directory; restore it before enabling control. Alertmanager is intentionally absent, so alerts appear only in Prometheus/Grafana.

Prometheus storage retention is configurable, but its storage alert uses a conservative fixed 9-GB threshold. Adjust the expression when changing the size limit. Grafana provisioning is Git-controlled; its volume stores users and preferences. Backups stop Prometheus/Grafana briefly for consistent volume archives.
