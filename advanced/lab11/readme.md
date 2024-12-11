# Kubernetes Network Policies Tutorial

A comprehensive guide and examples for implementing Kubernetes Network Policies in different scenarios.

## Overview

This repository provides practical examples and tutorials for implementing Kubernetes Network Policies, including:
- Basic deny/allow policies
- Microservice communication
- Multi-tenant isolation
- Advanced use cases

## Prerequisites

- Kubernetes cluster (1.20+)
- CNI plugin with NetworkPolicy support (Calico, Cilium, etc.)
- kubectl configured
- Basic understanding of Kubernetes networking

## Quick Start

1. Clone this repository:
```bash
git clone https://github.com/yourusername/k8s-network-policies
cd k8s-network-policies
```

2. Set up a test cluster:
```bash
./scripts/setup-cluster.sh
```

## Repository Structure

```
.
├── examples/
│   ├── 01-basic-policies/
│   │   ├── deny-all.yaml
│   │   └── allow-specific.yaml
│   ├── 02-microservices/
│   │   ├── frontend-backend.yaml
│   │   └── database.yaml
│   └── 03-advanced/
│       ├── multi-tenant.yaml
│       └── egress-control.yaml
├── demo/
│   ├── complete-stack/
│   └── scenarios/
├── scripts/
│   ├── setup-cluster.sh
│   └── cleanup.sh
└── docs/
    ├── diagrams/
    └── scenarios/
```

## Basic Examples

### 1. Default Deny All Traffic

```yaml
# examples/01-basic-policies/deny-all.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
  namespace: default
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
```

### 2. Allow Frontend to Backend

```yaml
# examples/02-microservices/frontend-backend.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend-to-backend
  namespace: default
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 8080
```

## Scenarios & Demos

### Basic Demo Setup

1. Create test namespaces:
```bash
kubectl create namespace prod
kubectl create namespace dev
```

2. Label namespaces:
```bash
kubectl label namespace prod environment=production
kubectl label namespace dev environment=development
```

3. Deploy test applications:
```bash
kubectl apply -f demo/complete-stack/
```

### Testing Network Policies

Test connectivity between pods:
```bash
# Test frontend to backend communication
kubectl -n prod exec -it $(kubectl -n prod get pod -l app=frontend -o jsonpath='{.items[0].metadata.name}') -- \
  curl http://backend:8080

# Test blocked communication
kubectl -n dev exec -it $(kubectl -n dev get pod -l app=frontend -o jsonpath='{.items[0].metadata.name}') -- \
  curl http://backend.prod:8080
```

## Advanced Examples

### Multi-tenant Isolation

```yaml
# examples/03-advanced/multi-tenant.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: tenant-isolation
spec:
  podSelector:
    matchLabels:
      tenant: tenant1
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          tenant: tenant1
  egress:
  - to:
    - podSelector:
        matchLabels:
          tenant: tenant1
```

## Best Practices

1. **Default Deny**
   - Start with restrictive policies
   - Add specific allowances as needed

2. **Documentation**
   - Label all resources consistently
   - Document policy intentions
   - Keep diagrams updated

3. **Testing**
   - Regular connectivity tests
   - Maintain test cases
   - Monitor policy effectiveness

4. **Security**
   - Regular policy audits
   - Follow principle of least privilege
   - Monitor denied connections

## Scripts

### Setup Script
```bash
#!/bin/bash
# scripts/setup-cluster.sh

# Create kind cluster with Calico
cat <<EOF | kind create cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
  disableDefaultCNI: true
  podSubnet: "192.168.0.0/16"
nodes:
- role: control-plane
- role: worker
- role: worker
EOF

# Install Calico
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

# Wait for Calico to be ready
kubectl -n kube-system wait --for=condition=ready pod -l k8s-app=calico-node --timeout=90s
```

### Cleanup Script
```bash
#!/bin/bash
# scripts/cleanup.sh

# Delete all network policies
kubectl delete networkpolicy --all --all-namespaces

# Delete test namespaces
kubectl delete namespace prod dev

# Optional: Delete cluster
kind delete cluster
```

## Contributing

1. Fork the repository
2. Create your feature branch
3. Submit a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Kubernetes Network Policy Documentation
- Calico Project
- Container Network Interface (CNI) Specification
