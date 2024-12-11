# Kubernetes Network Policies Training Lab

A hands-on training guide for understanding and implementing Kubernetes Network Policies using kind (Kubernetes in Docker).

## Prerequisites

- Docker installed
- kind installed
- kubectl installed
- Basic understanding of Kubernetes concepts

## Lab Setup

1. Create a kind cluster configuration with Calico CNI:

```yaml
# kind-config.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
  disableDefaultCNI: true  # Disable default CNI
  podSubnet: "192.168.0.0/16"  # Calico's default subnet
nodes:
- role: control-plane
- role: worker
- role: worker
```

2. Create the cluster:
```bash
kind create cluster --name netpol-lab --config kind-config.yaml
```

3. Install Calico CNI:
```bash
kubectl apply -f https://docs.projectcalico.org/v3.25/manifests/calico.yaml
```

## Lab Exercises

### 1. Understanding Default Behavior

1. Create test namespaces:
```bash
kubectl create namespace frontend
kubectl create namespace backend
kubectl create namespace database
```

2. Deploy test applications:
```yaml
# frontend-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: frontend
  namespace: frontend
  labels:
    name: frontend
spec:
  containers:
  - name: nginx
    image: nginx
---
# backend-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: backend
  namespace: backend
  labels:
    name: backend
spec:
  containers:
  - name: nginx
    image: nginx
```

### 2. Basic Network Policy Implementation

#### PodSelector Example
```yaml
# backend-policy.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-network-policy
  namespace: backend
spec:
  podSelector:
    matchLabels:
      name: backend
  policyTypes:    
  - Ingress    
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          name: frontend
    ports:
    - port: 8080
      protocol: TCP
```

### 3. Namespace Policies

#### NamespaceSelector Example
```yaml
# namespace-policy.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: namespace-policy
  namespace: backend
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: frontend
```

### 4. IP Block Rules

```yaml
# ip-block-policy.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: ip-block-policy
spec:
  podSelector:
    matchLabels:
      name: backend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - ipBlock:
        cidr: 192.168.0.0/16
    ports:
    - port: 8080
      protocol: TCP
```

## Practical Exercises

### Exercise 1: Implementing Basic Isolation

1. Create default deny policy:
```bash
kubectl apply -f https://raw.githubusercontent.com/yourusername/netpol-training/main/policies/default-deny.yaml
```

2. Test isolation:
```bash
# Test pod communication
kubectl exec -n frontend frontend -- curl http://backend.backend
# Should fail
```

### Exercise 2: Allowing Specific Traffic

1. Apply frontend-to-backend policy:
```bash
kubectl apply -f policies/frontend-backend.yaml
```

2. Verify communication:
```bash
# Should now succeed
kubectl exec -n frontend frontend -- curl http://backend.backend
```

## Testing and Verification

### Network Policy Testing Tools

1. Deploy testing pod:
```bash
kubectl run test-pod --image=nicolaka/netshoot -n frontend -- sleep 3600
```

2. Test connectivity:
```bash
kubectl exec -it test-pod -n frontend -- curl -v telnet://backend.backend:80
```

## Common Troubleshooting

### 1. Policy Not Working
- Check CNI installation:
```bash
kubectl get pods -n kube-system | grep calico
```

- Verify policy syntax:
```bash
kubectl describe networkpolicy <policy-name> -n <namespace>
```

### 2. Unexpected Blocking
```bash
# Debug with netshoot
kubectl run tmp-shell --rm -i --tty --image=nicolaka/netshoot -- /bin/bash
```

## Best Practices

1. **Start with Default Deny**
   - Implement default deny policies first
   - Add specific allowances as needed

2. **Policy Organization**
   - Use clear naming conventions
   - Document policy purposes
   - Keep policies focused

3. **Testing**
   - Test before enforcement
   - Maintain test cases
   - Document expected behavior

## Cleanup

Remove the lab environment:
```bash
kind delete cluster --name netpol-lab
```

## Additional Resources

- [Kubernetes Network Policies Documentation](https://kubernetes.io/docs/concepts/services-networking/network-policies/)
- [Calico Network Policy Documentation](https://docs.projectcalico.org/security/network-policy)
- [Network Policy Editor](https://editor.cilium.io/)

## Contributing

Feel free to submit issues and enhancement requests!

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
