## Node Selection for DaemonSets

You can configure DaemonSets to run only on specific nodes using node selectors and affinity rules. This is useful when you want to run certain workloads only on nodes with specific characteristics (e.g., nodes with GPUs, specific instance types, or designated roles).

### Using NodeSelector

1. Create a DaemonSet configuration with node selector (`fluentd-with-selector.yaml`):

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: fluentd
spec:
  selector:
    matchLabels:
      name: fluentd
  template:
    metadata:
      labels:
        name: fluentd
    spec:
      nodeSelector:
        log-collection-enabled: "true"
      containers:
        - name: fluentd-elasticsearch
          image: quay.io/fluentd_elasticsearch/fluentd:latest
```

2. Label specific nodes where you want the DaemonSet to run:

```bash
# Label the second worker node
kubectl label node daemonset-demo-worker2 log-collection-enabled=true
```

3. Apply the DaemonSet configuration:

```bash
kubectl apply -f fluentd-with-selector.yaml
```

4. Verify the deployment:

```bash
# Check DaemonSet status
kubectl get daemonsets
```

Expected output:
```
NAME      DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR                 AGE
fluentd   1         1         1       1            1           log-collection-enabled=true   13s
```

5. Verify pod placement:

```bash
kubectl get pods -o wide
```

Expected output:
```
NAME            READY   STATUS    RESTARTS   AGE     IP           NODE
fluentd-dflnq   1/1     Running   0          8m55s   10.244.1.3   daemonset-demo-worker2
```

### Using Node Affinity

For more complex node selection, you can use node affinity rules. Here's an example:

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: fluentd
spec:
  selector:
    matchLabels:
      name: fluentd
  template:
    metadata:
      labels:
        name: fluentd
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: log-collection-enabled
                operator: In
                values:
                - "true"
              - key: node-role.kubernetes.io/worker
                operator: Exists
      containers:
        - name: fluentd-elasticsearch
          image: quay.io/fluentd_elasticsearch/fluentd:latest
```

This configuration will run the DaemonSet only on worker nodes that have the `log-collection-enabled=true` label.

### Managing Node Labels

Common node label operations:

```bash
# Add a label to a node
kubectl label node daemonset-demo-worker2 log-collection-enabled=true

# Remove a label from a node
kubectl label node daemonset-demo-worker2 log-collection-enabled-

# Show node labels
kubectl get node --show-labels

# Show nodes with a specific label
kubectl get nodes -l log-collection-enabled=true
```

### Testing Node Selection

1. Label additional nodes:
```bash
kubectl label node daemonset-demo-worker3 log-collection-enabled=true
```

2. Watch the DaemonSet create new pods:
```bash
kubectl get pods -o wide -w
```

3. Remove labels to see pods being removed:
```bash
kubectl label node daemonset-demo-worker3 log-collection-enabled-
```

## Best Practices for Node Selection

1. **Label Planning**
   - Use meaningful label names
   - Document label schema
   - Consider using namespaced labels (e.g., `example.com/log-collection-enabled`)

2. **Security Considerations**
   - Restrict label modification permissions
   - Use RBAC to control who can modify node labels

3. **Maintenance**
   - Regularly audit node labels
   - Keep label documentation up to date
   - Use labels consistently across your cluster

[Previous sections about cleanup, troubleshooting, etc. remain the same...]
