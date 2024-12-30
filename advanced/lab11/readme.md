# Kubernetes Network Policies Training Lab

A hands-on training guide for understanding and implementing Kubernetes Network Policies using kind (Kubernetes in Docker).

## Table of Contents
- [Prerequisites](#prerequisites)
- [Lab Setup](#lab-setup)
- [Lab Exercises](#lab-exercises)
- [Testing and Verification](#testing-and-verification)
- [Troubleshooting Guide](#troubleshooting-guide)
- [Best Practices](#best-practices)

## Prerequisites

- Docker installed and running
- [kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation) v0.20.0 or higher
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) v1.28.0 or higher
- Basic understanding of Kubernetes concepts

## Lab Setup

1. Clone this repository:

2. Create the kind cluster:
```
kind create cluster --name netpol-lab --config kind-config.yaml
```

3. Install Calico CNI:
```
kubectl apply -f https://docs.projectcalico.org/v3.25/manifests/calico.yaml
```

4. Verify Calico installation:
```
kubectl wait --for=condition=ready pods -l k8s-app=calico-node -n kube-system --timeout=90s
```

## Lab Exercises

### 1. Basic Network Policy Implementation

1. Create test namespaces and deployments:
```
kubectl apply -f deployments.yaml
```

2. Verify pods are running:
```
kubectl get pods -n frontend
kubectl get pods -n backend
```

3. Test connectivity before applying policies:
```
./test-connectivity.sh before
```

4. Apply basic network policies:
```
kubectl apply -f 
```

5. Test connectivity after policies:
```
./scripts/test-connectivity.sh after
```

### 2. Advanced Policy Scenarios

Follow the exercises in the [exercises](./exercises/) directory for:
- Namespace isolation
- IP block rules
- Egress policies
- Mixed policy types

## Directory Structure
```
.
├── config/
│   ├── kind-config.yaml
│   └── calico.yaml
├── manifests/
│   ├── namespaces.yaml
│   └── deployments.yaml
├── policies/
│   ├── basic/
│   └── advanced/
├── scripts/
│   ├── setup.sh
│   └── test-connectivity.sh
├── exercises/
│   └── README.md
└── tests/
    └── e2e/
```

## Testing and Verification

Run the provided test suite:
```
./scripts/run-tests.sh
```

This will verify:
- Cluster setup
- Policy application
- Network connectivity
- Expected isolation

## Troubleshooting Guide

Common issues and solutions are documented in [TROUBLESHOOTING.md](./docs/TROUBLESHOOTING.md).

## Best Practices

1. **Default Deny First**
   - Always start with default deny policies
   - Add specific allowances incrementally

2. **Policy Organization**
   - Use clear naming conventions
   - Group related policies
   - Document policy purposes

3. **Testing**
   - Run tests before applying to production
   - Maintain test cases
   - Document expected behavior

