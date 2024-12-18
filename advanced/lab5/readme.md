# Kubernetes HPA Lab with Kind
This repository contains a hands-on lab for implementing Horizontal Pod Autoscaling (HPA) in a Kind Kubernetes cluster.

## Prerequisites

- Docker installed
- Kind installed
- kubectl installed
- Helm v3 installed

## Setup Kind Cluster

1. Create a Kind cluster configuration:

```
# kind-config.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
- role: worker
```

2. Create the cluster:

```
kind create cluster --name hpa-demo --config kind-config.yaml
```

## Install Metrics Server

1. Create metrics-server configuration for Kind:

```kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.5.0/components.yaml
```
Apply the patch for the certificate issue, create file named metric-server-patch.yaml, and fill it with these lines

```
spec:
template:
spec:
containers:
- args:
- --cert-dir=/tmp
- --secure-port=443
- --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
- --kubelet-use-node-status-port
- --metric-resolution=15s
- --kubelet-insecure-tls
name: metrics-server```

2. Apply the configuration:

```
kubectl patch deployment metrics-server -n kube-system --patch "$(cat metric-server-patch.yaml)"
```

## Deploy Demo Application

1. Create the demo application:

```yaml
# demo-app.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: demo
spec:
  selector:
    matchLabels:
      app: demo
  template:
    metadata:
      labels:
        app: demo
    spec:
      containers:
      - name: demo
        image: k8s.gcr.io/hpa-example
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: 200m
            memory: 256Mi
          limits:
            cpu: 500m
            memory: 512Mi
---
apiVersion: v1
kind: Service
metadata:
  name: demo
spec:
  ports:
  - port: 80
  selector:
    app: demo
```

2. Apply the deployment:

```bash
kubectl apply -f demo-app.yaml
```

## Configure HPA

1. Create HPA configuration:

```yaml
# hpa.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: demo
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: demo
  minReplicas: 1
  maxReplicas: 5
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
```

2. Apply HPA:

```bash
kubectl apply -f hpa.yaml
```

## Test HPA

1. Monitor HPA status:

```bash
kubectl get hpa demo -w
```

2. Generate load:

```bash
# In a separate terminal
kubectl run -i --tty load-generator --rm --image=busybox:1.28 --restart=Never -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://demo; done"
```

3. Watch scaling:

```bash
kubectl get deployments demo -w
```

## Clean Up

Remove the test environment:

```bash
# Stop load generator (Ctrl+C)
kind delete cluster --name hpa-demo
```

## Troubleshooting

### Common Issues

1. Metrics Server not working:
```bash
kubectl -n kube-system logs -l k8s-app=metrics-server
```

2. HPA not scaling:
```bash
kubectl describe hpa demo
```

3. Pod resource usage:
```bash
kubectl top pods
```

### Solutions

- Ensure metrics-server is running with proper flags for Kind
- Verify resource requests/limits are set
- Check node capacity is sufficient

## Additional Resources

- [Kind Documentation](https://kind.sigs.k8s.io/)
- [Kubernetes HPA Documentation](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)
- [Metrics Server Documentation](https://github.com/kubernetes-sigs/metrics-server)

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
