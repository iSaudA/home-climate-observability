"""Parse project YAML while accepting Home Assistant include tags."""

from pathlib import Path

import yaml


class HomeAssistantLoader(yaml.SafeLoader):
    pass


def _unknown(loader: HomeAssistantLoader, tag_suffix: str, node: yaml.Node):
    del tag_suffix
    if isinstance(node, yaml.ScalarNode):
        return loader.construct_scalar(node)
    if isinstance(node, yaml.SequenceNode):
        return loader.construct_sequence(node)
    return loader.construct_mapping(node)


HomeAssistantLoader.add_multi_constructor("!", _unknown)

for path in sorted((*Path(".").rglob("*.yml"), *Path(".").rglob("*.yaml"))):
    with path.open(encoding="utf-8") as stream:
        yaml.load(stream, Loader=HomeAssistantLoader)
    print(f"valid YAML: {path}")
