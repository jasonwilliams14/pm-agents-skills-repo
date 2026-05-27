---
name: python-dev-standard
description: Expert Python development following modern best practices (Python 3.10+). Use when building, refactoring, or testing Python applications that require Pydantic, type hinting, Google-style docstrings, and maintainable async code using a plan-validate-execute loop.
---

# Python Development Standard

This skill enforces high-quality, modern Python development practices. Use this skill for all Python-related tasks to ensure consistency, reliability, and maintainability.

## Core Mandates

- **Python Version**: 3.10+ (Prefer 3.12+ if available).
- **Type Hinting**: Mandatory for all function signatures and complex variables.
- **Data Modeling**: Use Pydantic v2 for all data structures and configuration.
- **Documentation**: Use Google-style docstrings for all modules, classes, and functions.
- **Concurrency**: Prefer `asyncio` for I/O-bound tasks.
- **Workflow**: Follow the **Plan-Validate-Execute** loop for every change.

## Workflow: Plan-Validate-Execute

Always follow this loop for implementation tasks:

1.  **Plan**: Research the requirements and draft the implementation strategy.
2.  **Validate**: (Optional but recommended) Write a reproduction script or a failing test case to confirm the need for the change or the current state.
3.  **Execute**: Implement the code changes surgically.
4.  **Verify**: Run tests and linters to confirm the implementation is correct and follows standards.

See [workflow.md](references/workflow.md) for details.

## Reference Materials

- **Pydantic Patterns**: Best practices for data validation. See [pydantic-patterns.md](references/pydantic-patterns.md).
- **Async Best Practices**: Patterns for maintainable asynchronous code. See [async-best-practices.md](references/async-best-practices.md).
- **Docstring Guide**: Examples of Google-style docstrings. See [docstring-guide.md](references/docstring-guide.md).

## Technical Baseline

- **Pydantic**: Strict v2 usage.
- **Async**: `asyncio`, `httpx` (for async HTTP), `aiosqlite`/`motor` (for async DB).
- **Testing**: `pytest`, `pytest-asyncio`.
- **Linting**: `ruff` (preferred), `mypy`.
