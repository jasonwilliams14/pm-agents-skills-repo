# GitOps LLM Serving & Model Deployment Playbook

## 1. Local Validation (k3d Cluster)
- **Cluster Spin-up:** Verify local GPU pass-through or compute mock availability on the `k3d` instance.
- **Helm Dry-Run:** Execute `helm template` on model serving charts (`vllm`, `triton`, or `llm-d`) to ensure value interpolation is clean.
- **Secret Management:** Validate that Hugging Face (`hf-token`) or GCP registry authentication secrets are injected securely via local secrets or sops.

## 2. Infrastructure & Model Serving Declaration
- **Compute Isolation:** Define explicit node selectors and tolerations for specialized accelerator nodes (NVIDIA H100/A100 in GCP, local mocks in k3d).
- **Runtime Configuration:** Enforce model server runtime settings (vLLM PagedAttention configuration, max model length, and KV cache allocation limits).
- **GitOps Commit:** Push manifests to the cluster tracking branch, staging the deployment via FluxCD source controllers.

## 3. Custom Resource Manifest Preparation
- **InferencePool:** Define the backend pool targeting the model servers, binding it to the appropriate metric endpoints.
- **InferenceModel:** Map user-facing model endpoints (e.g., `llama-3-chat`) to the underlying `InferencePool`, specifying weights or LoRA adapter targets.

## 4. Reconciliation Verification
- **Flux Watch:** Monitor state reconciliation via `flux get kustomizations --watch`.
- **Pod Readiness:** Verify pod initialization and execution states. Ensure model weights are fully loaded into GPU memory before the readiness probe passes.