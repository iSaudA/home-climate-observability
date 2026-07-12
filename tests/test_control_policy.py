import math

import pytest

from tools.control_policy import calculate_target


@pytest.mark.parametrize(
    ("change", "expected"),
    [(0.0, 24.0), (0.59, 24.0), (0.7, 23.0), (-0.7, 25.0), (0.6, 23.0), (-0.6, 25.0)],
)
def test_policy(change, expected):
    assert calculate_target(change) == expected


def test_minimum_clamp():
    assert calculate_target(1, baseline=22, minimum=22) == 22


def test_maximum_clamp():
    assert calculate_target(-1, baseline=26, maximum=26) == 26


@pytest.mark.parametrize("kwargs", [{"minimum": 27, "maximum": 26}, {"threshold": -0.1}])
def test_invalid_configuration(kwargs):
    with pytest.raises(ValueError):
        calculate_target(0, **kwargs)


@pytest.mark.parametrize("value", [None, "unknown", float("nan"), math.inf, True])
def test_unavailable_or_non_numeric_data(value):
    with pytest.raises(ValueError):
        calculate_target(value)


def test_policy_never_ratchets_from_previous_result():
    first = calculate_target(1.0)
    second = calculate_target(1.0)
    assert first == second == 23.0
