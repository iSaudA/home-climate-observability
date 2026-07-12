# Entity mapping

After UI onboarding, open **Settings → Devices & services → Helpers** (or the Climate dashboard) and set:

- Indoor temperature source: the numeric Broadlink temperature sensor.
- Indoor humidity source: the numeric Broadlink humidity sensor.
- Weather source: the `weather` entity whose attributes include temperature and humidity.
- Broadlink remote source: the learned-command-capable `remote` entity.
- Optional native climate source: leave empty unless using that backend.

Use entity IDs only—not device IDs, addresses, or friendly names. Source helpers are the only hardware-specific mapping. Downstream automation and dashboards use `sensor.climate_*`, `binary_sensor.climate_controller_healthy`, and the AC helpers/counters.

Missing or non-numeric sources make normalized sensors unavailable; they never become zero. Leave `input_boolean.climate_automation_enabled` off until normalized values, trend history, and the adapter are healthy.
