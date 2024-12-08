# Kubernetes RBAC Guide

A comprehensive guide to implementing Role-Based Access Control (RBAC) in Kubernetes clusters.

## Table of Contents
- [Overview](#overview)
- [Core Components](#core-components)
- [Implementation Guide](#implementation-guide)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

## Overview

RBAC (Role-Based Access Control) in Kubernetes provides fine-grained access policies for cluster resources. This guide covers implementation, best practices, and common troubleshooting steps.

### Key Features
- Granular permission management
- Namespace-level and cluster-level controls
- Integration with service accounts and users
- Support for custom roles and policies

## Core Components

### 1. Roles and ClusterRoles
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
  namespace: default
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "watch", "list"]
```

### 2. RoleBindings and ClusterRoleBindings
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-pods
  namespace: default
subjects:
- kind: ServiceAccount
  name: demo-sa
  namespace: default
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

## Implementation Guide

### Prerequisites
- Kubernetes cluster with RBAC enabled
- kubectl CLI tool
- Administrative access to the cluster

### Verify RBAC Status
```bash
kubectl api-versions | grep rbac
```

### Basic Setup Steps

1. Create Service Account
```bash
kubectl create serviceaccount demo-user
TOKEN=$(kubectl create token demo-user)
```

2. Configure kubectl
```bash
kubectl config set-credentials demo-user --token=$TOKEN
kubectl config set-context demo-user-context --cluster=default --user=demo-user
```

3. Create Role
```bash
kubectl apply -f role.yaml
```

4. Create RoleBinding
```bash
kubectl apply -f rolebinding.yaml
```

## Best Practices

### Security Guidelines
1. Enable RBAC by default
2. Follow least privilege principle
3. Avoid wildcard permissions
4. Regular audit of roles and bindings
5. Use namespaces for isolation

### Role Management
```yaml
# Good Practice - Specific permissions
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]
  resourceNames: ["web-frontend"]

# Avoid - Overly broad permissions
rules:
- apiGroups: ["*"]
  resources: ["*"]
  verbs: ["*"]
```

## Troubleshooting

### Common Issues

1. Permission Denied
```bash
# Check permissions
kubectl auth can-i create pods
kubectl auth can-i --list
```

2. Role Verification
```bash
kubectl describe role role-name
kubectl describe rolebinding binding-name
```

3. Context Issues
```bash
kubectl config current-context
kubectl config view
```

## Quick Reference

### Supported Verbs
- get
- list
- watch
- create
- update
- patch
- delete
- deletecollection

### Common API Groups
- "" (core)
- apps
- batch
- rbac.authorization.k8s.io
- networking.k8s.io

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit changes
4. Submit pull request

## License

MIT License - see [LICENSE.md](LICENSE.md)
