# k3d Demo Cluster Script

Standard cluster setup for Gateway API and AI Inference POCs:

```bash
k3d cluster create demo \
  --port "80:80@loadbalancer" \
  --port "443:443@loadbalancer" \
  --k3s-arg "--disable=traefik@server:0" \
  --agents 2
```
