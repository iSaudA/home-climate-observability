# Broadlink setup

1. Use the manufacturer app only to join the device to the trusted LAN.
2. In Home Assistant, open **Settings → Devices & services → Add integration → Broadlink**. Use discovery where possible; do not commit device addresses or identifiers.
3. Copy the resulting `remote` entity ID into the mapping helper described in `entity-mapping.md`.
4. In **Developer tools → Actions**, learn each full-state command:

```yaml
action: remote.learn_command
target:
  entity_id: remote.replace_with_your_entity
data:
  device: air_conditioner
  command:
    - cool_22_auto
    - cool_23_auto
    - cool_24_auto
    - cool_25_auto
    - cool_26_auto
```

For each prompt, set the physical remote to AC on, cool mode, the named temperature, auto fan, and one consistent swing state. Test safely while automation remains disabled:

```yaml
action: remote.send_command
target:
  entity_id: remote.replace_with_your_entity
data:
  device: air_conditioner
  command: cool_24_auto
```

Learned codes live in Home Assistant `.storage`; never edit or commit that directory. Accepted sends provide no physical acknowledgement. Preserve the physical remote as the manual override: disabling the automation stops future automatic commands without preventing monitoring.
