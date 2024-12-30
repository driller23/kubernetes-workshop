# Kubernetes ConfigMap Example 1

apply yaml

```
kubectl apply -f demo-config.yaml
```

## get configmap
```kubectl get configmaps```

OR inspect
```
kubectl describe configmap demo-config
```

OR
```kubectl get configmap demo-config -o jsonpath='{.data}' | jq```

## envForm example
```kubectl apply -f demo-pod.yaml```

# config immutable

```
kubectl apply -f demo-config-immutable.yaml
configmap/demo-config-immutable created
```
Now try changing the ConfigMap, such as by changing foo from bar to baz:

```
data:
  foo: baz
```
When you re-apply the manifest, you’ll see a Forbidden error because the immutable ConfigMap doesn’t permit modifications:

```
kubectl apply -f demo-config-immutable.yaml
```

The ConfigMap "demo-config-immutable" is invalid: data: Forbidden: field is immutable when `immutable` is set

# Kubernetes ConfigMap Example 2

This repository demonstrates how to use Kubernetes ConfigMaps to manage configuration files for your applications.

## Prerequisites

- Kubernetes cluster (minikube, kind, or cloud provider cluster)
- kubectl installed and configured
- Basic understanding of Kubernetes concepts

## Directory Structure
```
.
├── README.md
├── configmap.yaml
└── game.properties
```

## Quick Start

1. Create the ConfigMap in your cluster:
```bash
kubectl apply -f configmap.yaml
```

2. Verify the ConfigMap was created:
```bash
kubectl get configmap game-config
kubectl describe configmap game-config
```

## Detailed Instructions

### 1. Creating the ConfigMap

You can create the ConfigMap in several ways:

Using the YAML file:
```bash
kubectl apply -f configmap.yaml
```

Directly from the properties file:
```bash
kubectl create configmap game-config --from-file=game.properties
```

From literal values:
```bash
kubectl create configmap game-config \
    --from-literal=enemy.types=aliens,monsters \
    --from-literal=player.maximum-lives=5
```

### 2. Verify ConfigMap

Check if the ConfigMap was created:
```bash
kubectl get configmaps
```

View ConfigMap details:
```bash
kubectl describe configmap game-config
```

### 3. Using the ConfigMap

The sample pod will mount the ConfigMap as a volume and display its contents:
```bash
kubectl apply -f configmap.yaml
kubectl logs game-pod
```

Expected output:
```
enemy.types=aliens,monsters
player.maximum-lives=5
player.initial-lives=3
player.level=1
```

## Cleanup

Remove the resources when you're done:
```bash
kubectl delete pod game-pod
kubectl delete configmap game-config
```

## Troubleshooting

### Common Issues

1. **ConfigMap Not Found**
   - Check if ConfigMap exists in the correct namespace
   - Verify ConfigMap name matches in both files
   - Check for typos in key names

2. **Mount Issues**
   - Verify volume mount paths
   - Check pod events for mounting errors
   - Ensure proper permissions on mounted files

### Debug Commands

Check pod status:
```bash
kubectl describe pod game-pod
```

View pod logs:
```bash
kubectl logs game-pod
```

Inspect mounted files:
```bash
kubectl exec game-pod -- ls /etc/config
kubectl exec game-pod -- cat /etc/config/game.properties
```

## Best Practices

1. Keep configurations simple and focused
2. Use meaningful names for ConfigMaps
3. Consider using multiple ConfigMaps for different aspects of your application
4. Use labels and annotations for better organization
5. Document all configuration options

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.


