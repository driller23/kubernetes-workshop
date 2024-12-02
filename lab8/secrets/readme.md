# Kubernetes Secrets Lab

This repository demonstrates how to work with Kubernetes Secrets by creating and using secrets as environment variables in a Pod.

## Prerequisites

- Kubernetes cluster (minikube, kind, or cloud provider cluster)
- kubectl installed and configured
- Basic understanding of Kubernetes concepts

## Directory Structure
```
.
├── README.md
├── secret.yaml
└── pod.yaml
```

## Quick Start

1. Create the secret in your cluster:
```bash
kubectl apply -f secret.yaml
```

2. Deploy the pod that uses the secret:
```bash
kubectl apply -f pod.yaml
```

3. Verify the pod is running:
```bash
kubectl get pod env-pod
```

## Detailed Instructions

### 1. Create and Verify Secrets

Create the secret using the provided configuration:
```bash
kubectl apply -f secret.yaml
```

Verify the secret was created:
```bash
# List all secrets
kubectl get secrets

# Get details about our secret
kubectl describe secret database-credentials
```

### 2. Deploy and Test Pod

Deploy the pod that will use the secret:
```bash
kubectl apply -f pod.yaml
```

Check pod status:
```bash
kubectl get pod env-pod
```

View the pod logs to see the environment variables:
```bash
kubectl logs env-pod
```

Expected output:
```
Username: admin123 Password: supersecret456
```

### 3. Verify Environment Variables Inside Pod

You can verify the environment variables are set correctly inside the pod:
```bash
# Execute a shell in the pod
kubectl exec -it env-pod -- /bin/sh

# Check environment variables
env | grep -E 'USER|PASSWORD'
```

## Cleanup

Remove the resources when you're done:
```bash
kubectl delete pod env-pod
kubectl delete secret database-credentials
```

## Troubleshooting

### Pod Won't Start
Check pod events:
```bash
kubectl describe pod env-pod
```

### Secret Issues
Verify secret exists and has correct data:
```bash
kubectl describe secret database-credentials
```

### Common Problems and Solutions

1. **Secret Not Found**
   - Ensure secret and pod are in the same namespace
   - Verify secret name matches in both files
   - Check for typos in key names

2. **Permission Issues**
   - Ensure proper RBAC permissions are set
   - Verify cluster role bindings if using custom service accounts

3. **Environment Variables Not Showing**
   - Check secret keys match exactly
   - Verify base64 encoding is correct
   - Check pod events for mounting errors

## Security Best Practices

1. Always use RBAC to control access to secrets
2. Rotate secrets regularly
3. Use network policies to restrict pod-to-pod communication
4. Consider using external secret management solutions
5. Never commit unencrypted secret values to version control

## Contributing

Feel free to submit issues and enhancement requests!
