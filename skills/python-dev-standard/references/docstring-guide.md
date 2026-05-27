# Google Style Docstring Guide

Consistent documentation is critical for maintainability.

## Function Example
```python
def calculate_metrics(data: list[float], threshold: float = 0.5) -> dict[str, float]:
    """Calculates summary metrics for a given dataset.

    Args:
        data: A list of floats representing the input measurements.
        threshold: The cutoff value for high-pass filtering. Defaults to 0.5.

    Returns:
        A dictionary containing 'mean', 'max', and 'filtered_count'.

    Raises:
        ValueError: If the input data is empty.
    """
    if not data:
        raise ValueError("Data cannot be empty")
    # ...
```

## Class Example
```python
class MetricProcessor:
    """Processes raw data into actionable insights.

    Attributes:
        config: The application configuration settings.
        results: A cache of previously computed metrics.
    """
    def __init__(self, config: AppConfig):
        self.config = config
        self.results = {}
```

## Module Example
Add a module-level docstring at the very top of the file.
```python
"""
This module provides utilities for signal processing and telemetry data extraction.
It supports async operations and strictly validates input using Pydantic.
"""
```
