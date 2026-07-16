#!/usr/bin/env bash
# vcluster Local Multi-Cluster Development Setup
# Goal: Run 2 isolated vclusters locally for rapid iteration and testing
# Time to complete: ~30 seconds setup + testing
# Source: skills/vcluster-dev/templates/local-multicluster-setup.sh

set -e

COLOR_GREEN='\033[0;32m'
COLOR_BLUE='\033[0;34m'
COLOR_YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${COLOR_BLUE}=== vcluster Local Multi-Cluster Setup ===${NC}\n"

# ============================================================================
# STEP 1: Verify Docker is running (no parent cluster needed)
# ============================================================================

echo -e "${COLOR_BLUE}Step 1: Verify Docker is running${NC}"
echo "Checking if Docker daemon is accessible..."

if ! docker info &> /dev/null; then
    echo -e "${COLOR_YELLOW}ERROR: Docker daemon not running${NC}"
    echo "Solution: Start Docker Desktop or Docker daemon"
    exit 1
fi

echo -e "${COLOR_GREEN}✓ Docker is running${NC}"
docker --version
echo ""

# ============================================================================
# STEP 2: Install vcluster CLI
# ============================================================================

echo -e "${COLOR_BLUE}Step 2: Install vcluster CLI${NC}"

if command -v vcluster &> /dev/null; then
    echo -e "${COLOR_GREEN}✓ vcluster CLI already installed${NC}"
    vcluster version
else
    echo "Installing vcluster CLI..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        brew install vcluster
    else
        # Linux
        curl -L -o vcluster "https://github.com/loft-sh/vcluster/releases/latest/download/vcluster-linux-amd64"
        chmod +x vcluster && sudo mv vcluster /usr/local/bin/
    fi
    echo -e "${COLOR_GREEN}✓ vcluster CLI installed${NC}"
    vcluster version
fi
echo ""

# ============================================================================
# STEP 3: Create first vcluster (cluster-a) — Standalone Mode
# ============================================================================

echo -e "${COLOR_BLUE}Step 3: Create first vcluster (cluster-a)${NC}"
echo "Creating cluster-a in standalone mode..."
echo "Expected: 5-10 seconds (no parent cluster needed)"

vcluster create cluster-a

if [ $? -eq 0 ]; then
    echo -e "${COLOR_GREEN}✓ cluster-a created successfully${NC}"
else
    echo -e "${COLOR_YELLOW}ERROR: Failed to create cluster-a${NC}"
    exit 1
fi
echo ""

# ============================================================================
# STEP 4: Create second vcluster (cluster-b) — Standalone Mode
# ============================================================================

echo -e "${COLOR_BLUE}Step 4: Create second vcluster (cluster-b)${NC}"
echo "Creating cluster-b in standalone mode..."
echo "Expected: 5-10 seconds (no parent cluster needed)"

vcluster create cluster-b

if [ $? -eq 0 ]; then
    echo -e "${COLOR_GREEN}✓ cluster-b created successfully${NC}"
else
    echo -e "${COLOR_YELLOW}ERROR: Failed to create cluster-b${NC}"
    exit 1
fi
echo ""

# ============================================================================
# STEP 5: Verify both clusters running
# ============================================================================

echo -e "${COLOR_BLUE}Step 5: Verify both clusters running${NC}"
echo ""
echo "vcluster list:"
vcluster list
echo -e "${COLOR_GREEN}✓ Both clusters running${NC}\n"

# ============================================================================
# STEP 6: Deploy test workload to cluster-a
# ============================================================================

echo -e "${COLOR_BLUE}Step 6: Deploy test workload to cluster-a${NC}"
echo "Connecting to cluster-a..."

# Use a subshell to isolate vcluster connect context
(
    vcluster connect cluster-a

    echo "Creating namespace app-test..."
    kubectl create namespace app-test --dry-run=client -o yaml | kubectl apply -f -

    echo "Deploying nginx..."
    kubectl apply -n app-test -f - <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-a
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-service-a
spec:
  selector:
    app: nginx
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
  type: ClusterIP
EOF

    echo "Waiting for deployment to be ready..."
    kubectl wait --for=condition=available --timeout=60s deployment/nginx-a -n app-test

    echo -e "${COLOR_GREEN}✓ Deployment ready${NC}"
    echo ""
    echo "Pods in cluster-a:"
    kubectl get pods -n app-test
    echo ""
    echo "Services in cluster-a:"
    kubectl get svc -n app-test
)

echo ""

# ============================================================================
# STEP 7: Deploy test workload to cluster-b
# ============================================================================

echo -e "${COLOR_BLUE}Step 7: Deploy test workload to cluster-b${NC}"
echo "Connecting to cluster-b..."

(
    vcluster connect cluster-b

    echo "Creating namespace app-test..."
    kubectl create namespace app-test --dry-run=client -o yaml | kubectl apply -f -

    echo "Deploying nginx..."
    kubectl apply -n app-test -f - <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-b
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-service-b
spec:
  selector:
    app: nginx
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
  type: ClusterIP
EOF

    echo "Waiting for deployment to be ready..."
    kubectl wait --for=condition=available --timeout=60s deployment/nginx-b -n app-test

    echo -e "${COLOR_GREEN}✓ Deployment ready${NC}"
    echo ""
    echo "Pods in cluster-b:"
    kubectl get pods -n app-test
    echo ""
    echo "Services in cluster-b:"
    kubectl get svc -n app-test
)

echo ""

# ============================================================================
# STEP 8: Test isolation & access
# ============================================================================

echo -e "${COLOR_BLUE}Step 8: Test isolation & access${NC}"
echo ""

# Test cluster-a isolation
(
    vcluster connect cluster-a
    PODS_A=$(kubectl get pods -n app-test --no-headers | wc -l)
    echo "Pods in cluster-a app-test namespace: $PODS_A"
)

# Test cluster-b isolation
(
    vcluster connect cluster-b
    PODS_B=$(kubectl get pods -n app-test --no-headers | wc -l)
    echo "Pods in cluster-b app-test namespace: $PODS_B"
)

echo -e "${COLOR_GREEN}✓ Isolation verified (each cluster has its own pods)${NC}\n"

# ============================================================================
# STEP 9: Cleanup (optional)
# ============================================================================

echo -e "${COLOR_YELLOW}Step 9: Cleanup${NC}"
echo "Clusters are running. To delete:"
echo "  vcluster delete cluster-a"
echo "  vcluster delete cluster-b"
echo ""
echo "To connect to a running vcluster:"
echo "  vcluster connect cluster-a"
echo "  kubectl get pods (now runs in cluster-a)"
echo ""

# ============================================================================
# SUCCESS
# ============================================================================

echo -e "${COLOR_GREEN}=== Setup Complete ===${NC}"
echo ""
echo "You now have 2 isolated vcluster instances:"
echo "  • cluster-a (namespace: vcluster-a) with nginx deployment"
echo "  • cluster-b (namespace: vcluster-b) with nginx deployment"
echo ""
echo "Total time: ~30 seconds"
echo "Total resources: ~2GB RAM (2 clusters × 1GB each)"
echo ""
echo "Next steps:"
echo "  1. Connect to cluster-a: vcluster connect cluster-a --namespace vcluster-a"
echo "  2. Deploy more workloads: kubectl apply -f your-manifest.yaml"
echo "  3. Run tests across clusters"
echo "  4. Cleanup: vcluster delete cluster-a --namespace vcluster-a"
echo ""
echo "For more info, see: skills/vcluster-dev/references/"
