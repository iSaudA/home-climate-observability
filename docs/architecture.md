# Architecture

Home Assistant owns normalized climate entities, policy, persistence, traces, and the hardware adapter. The source entity IDs are centralized in helpers so dashboards and metrics remain stable when hardware names change. Broadlink and weather integrations remain UI-managed because Home Assistant stores their config entries securely in `.storage`, which is excluded from Git.

The control boundary is `script.apply_ac_target`. The policy supplies one bounded target; the script chooses either the default Broadlink full-state IR command or an optional native `climate` entity. No policy logic depends on the adapter.

The native backend accepts the configured 16–30°C helper range. The Broadlink adapter deliberately rejects anything outside 22–26°C because only those five full-state commands are learned.

Prometheus uses a Docker secret for the Home Assistant bearer token and a Compose `extra_hosts` alias mapped to `HOST_IP`. Grafana and cAdvisor are reachable only on the internal observability network. Node Exporter uses host networking and binds to that same configured trusted address.

The two subordinate Compose files can be operated separately. The root Compose file includes both for convenience.
