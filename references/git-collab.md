## 7. Git & Collaboration

- **Branching:** Atomic feature/fix branches (`feature/add-dynamic-routing`, `fix/nginx-timeout`). Never commit to `main`/`master` directly.
- **Commits:** Semantic messages (`feat:`, `fix:`, `docs:`, `chore:`, `test:`). Include manual testing steps in PRs, link related issues.
- **Code quality:** Run linter and test suite before declaring tasks complete. Type hints mandatory. `ruff` for Python, `pytest` for tests.
- **Architecture:** API-first designs, streaming-aware (SSE, WebSockets), infrastructure-as-code (Terraform, Helm, FluxCD).