"""Reference model for the Home Assistant weather adjustment policy."""

from __future__ import annotations

import math
from numbers import Real


def calculate_target(
    outdoor_change: Real,
    *,
    baseline: Real = 24.0,
    minimum: Real = 22.0,
    maximum: Real = 26.0,
    threshold: Real = 0.6,
) -> float:
    """Return a non-cumulative AC target based on outdoor temperature change."""
    values = (outdoor_change, baseline, minimum, maximum, threshold)
    if any(isinstance(value, bool) or not isinstance(value, Real) for value in values):
        raise ValueError("all policy inputs must be numeric")
    numeric = tuple(float(value) for value in values)
    if not all(math.isfinite(value) for value in numeric):
        raise ValueError("all policy inputs must be finite")
    change, base, low, high, boundary = numeric
    if low > high:
        raise ValueError("minimum must not exceed maximum")
    if boundary < 0:
        raise ValueError("threshold must be non-negative")

    adjustment = -1.0 if change >= boundary else 1.0 if change <= -boundary else 0.0
    return min(high, max(low, base + adjustment))
