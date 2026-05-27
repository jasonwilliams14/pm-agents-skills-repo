# Async Best Practices

Modern Python favors `asyncio` for high-performance I/O.

## Main Loop
```python
import asyncio

async def main() -> None:
    # Your code here
    pass

if __name__ == "__main__":
    asyncio.run(main())
```

## Context Managers
Always use `async with` for resources that support it (e.g., `httpx.AsyncClient`, database connections).

## Task Management
- Use `asyncio.gather()` for parallel execution of independent tasks.
- Use `asyncio.TaskGroup()` (Python 3.11+) for better error handling and structured concurrency.
- Avoid `loop.run_until_complete()` inside async functions.

## Avoid Blocking
- Never use `time.sleep()` in async code; use `asyncio.sleep()`.
- For CPU-bound tasks, use `asyncio.to_thread()` (Python 3.9+) or a `ProcessPoolExecutor`.

## Observability
Ensure all async operations are traced using OpenTelemetry.
```python
from opentelemetry import trace

tracer = trace.get_tracer(__name__)

async def fetch_data():
    with tracer.start_as_current_span("fetch_data"):
        # ...
```
