# Troubleshooting

- Home Assistant 401: create a dedicated long-lived token and ensure the secret file contains no surrounding quotes.
- Empty climate metrics: confirm normalized entities exist and inspect `scripts/discover-ha-metrics.sh` output.
- Unavailable normalized sensors: correct source helper entity IDs and verify weather attributes in Developer tools → States.
- No trend: allow approximately two hours of samples; the statistics sensor intentionally remains unavailable without data.
- No command: check automation enabled, controller health, 15-minute target stability, last-command age, and automation traces.
- Broadlink failure: verify the `remote` entity is available and manually send one learned full-state command. Do not configure rapid retries.
- Prometheus cannot reach host: ensure `HOST_IP` is an address reachable from Docker and permitted by the host firewall.
- Node Exporter down: ensure its configured bind address belongs to the host and port 9100 is restricted to the trusted LAN.
- cAdvisor missing containers: Docker Desktop and nonstandard runtimes may expose different mount paths; review security before adding mounts.
- Grafana has no climate data: confirm recording rules in Prometheus and reconcile actual Home Assistant metric names first.

Never paste tokens, device identifiers, or private network details into issues or logs.
