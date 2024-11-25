# Kubernetes DaemonSet Example

This repository demonstrates how to use Kubernetes DaemonSets to run pods on every node in your cluster. The example uses Fluentd as a logging system that needs to run on all nodes.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)

## Setup Multi-Node Cluster

1. First, create a configuration file for your kind cluster named `kind-config.yaml`:

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
- role: worker
- role: worker
```

2. Create a cluster using this configuration:

```bash
kind create cluster --name daemonset-demo --config kind-config.yaml
```

3. Verify the nodes are running:

```bash
kubectl get nodes
```

Expected output:
```
NAME                            STATUS   ROLES           AGE     VERSION
daemonset-demo-control-plane   Ready    control-plane   2m      v1.27.x
daemonset-demo-worker         Ready    <none>          1m45s   v1.27.x
daemonset-demo-worker2        Ready    <none>          1m45s   v1.27.x
daemonset-demo-worker3        Ready    <none>          1m45s   v1.27.x
```

## Deploy the DaemonSet

1. Create a file named `fluentd.yaml` with the following content:

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
      containers:
        - name: fluentd-elasticsearch
          image: quay.io/fluentd_elasticsearch/fluentd:latest
```

2. Apply the DaemonSet configuration:

```bash
kubectl apply -f fluentd.yaml
```

## Verify the Deployment

1. Check the status of the pods:

```bash
kubectl get pods -o wide
```

Expected output:
```
NAME            READY   STATUS    RESTARTS   AGE    IP           NODE
fluentd-6rqdg   1/1     Running   0          1m     10.244.2.2   daemonset-demo-worker2
fluentd-8v7pc   1/1     Running   0          1m     10.244.1.2   daemonset-demo-worker
fluentd-xv6bs   1/1     Running   0          1m     10.244.3.2   daemonset-demo-worker3
fluentd-zjbg4   1/1     Running   0          1m     10.244.0.2   daemonset-demo-control-plane
```

2. Check the DaemonSet status:

```bash
kubectl get daemonset
```

Expected output:
```
NAME      DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
fluentd   4         4         4       4            4           <none>          2m
```

## Understanding the Output

- **DESIRED**: Number of nodes that should be running the pod (equal to the number of nodes)
- **CURRENT**: Number of pods currently running
- **READY**: Number of pods ready to serve requests
- **UP-TO-DATE**: Number of pods updated to the latest desired configuration
- **AVAILABLE**: Number of pods available for use

## Common Operations

### Delete the DaemonSet

```bash
kubectl delete -f fluentd.yaml
```

### Scale the Cluster

1. Modify the `kind-config.yaml` to add more workers:

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
- role: worker
- role: worker
- role: worker  # Added new worker
```

2. Create a new cluster with the updated configuration:

```bash
kind delete cluster --name daemonset-demo
kind create cluster --name daemonset-demo --config kind-config.yaml
```

The DaemonSet will automatically schedule pods on all nodes, including the new one.

### View DaemonSet Details

```bash
kubectl describe daemonset fluentd
```

## Troubleshooting

### Check Pod Logs

```bash
# Replace pod-name with actual pod name
kubectl logs <pod-name>
```

### Check Pod Details

```bash
kubectl describe pod <pod-name>
```

### Check Node Status

```bash
kubectl describe node <node-name>
```

## Cleanup

Remove the kind cluster:

```bash
kind delete cluster --name daemonset-demo
```

## Additional Resources

- [Kubernetes DaemonSet Documentation](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/)
- [kind Documentation](https://kind.sigs.k8s.io/)
- [Fluentd Documentation](https://docs.fluentd.org/)

## Contributing

Feel free to submit issues and enhancement requests!

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
