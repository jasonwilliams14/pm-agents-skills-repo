# Plan-Validate-Execute Workflow

This workflow ensures that every change is intentional, verified, and correctly implemented.

## 1. Plan Phase
- **Research**: Identify the code to be modified and understand its dependencies.
- **Design**: Draft the implementation. Decide on data structures (Pydantic models) and function signatures.
- **Review**: Ensure the plan aligns with "The Jason Standard" (OTEL, strict typing, Pydantic v2).

## 2. Validate Phase (Reproduction)
- For bugs: Write a minimal reproduction script or a `pytest` test that fails.
- For features: Write a test case that describes the expected behavior.
- **Mandate**: Never fix a bug without first reproducing it.

## 3. Execute Phase
- Implement the changes based on the plan.
- Use surgical edits (`replace`) where possible to minimize noise.
- Ensure all docstrings and type hints are included.

## 4. Verify Phase
- Run the tests written in the Validate phase.
- Run project-wide tests to check for regressions.
- Run `ruff` or `flake8` and `mypy` to ensure linting and type safety.
- **Success Criteria**: Tests pass, linters are clean, and code is idiomatically correct.
