# Kubernetes Monitoring Setup with Kind

This repository provides a guide and configuration for setting up a comprehensive monitoring stack (Prometheus, Grafana, and Loki) on a Kind (Kubernetes in Docker) cluster. This setup is perfect for local development and testing.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [Kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Helm](https://helm.sh/docs/intro/install/)

## Cluster Setup

1. First, create a Kind cluster using our custom configuration:

```bash
kind create cluster --name monitoring-demo --config kind-config.yaml
```

## Installing the Monitoring Stack

### 1. Prometheus and Grafana Setup

1. Add the Prometheus community Helm repository:
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

2. Install the kube-prometheus-stack:
```bash
helm install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --values prometheus-values.yaml
```

3. Verify the installation:
```bash
kubectl get pods -n monitoring
```

### 2. Loki Setup

1. Add the Grafana Helm repository:
```bash
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
```

2. Install Loki and Promtail:
```bash
helm install loki grafana/loki-stack \
  --namespace monitoring \
  --values loki-values.yaml
```

3. Verify Loki installation:
```bash
kubectl get pods -n monitoring | grep loki
```

## Accessing the Dashboards

### Grafana

1. Port-forward the Grafana service:
```bash
kubectl port-forward svc/monitoring-grafana 3000:80 -n monitoring
```

2. Access Grafana at: http://localhost:3000
   - Default username: admin
   - Default password: prom-operator

### Prometheus

1. Port-forward the Prometheus service:
```bash
kubectl port-forward svc/monitoring-kube-prometheus-prometheus 9090:9090 -n monitoring
```

2. Access Prometheus at: http://localhost:9090

## Configuration Files

This repository includes the following configuration files:

- `kind-config.yaml`: Kind cluster configuration
- `prometheus-values.yaml`: Custom values for Prometheus stack
- `loki-values.yaml`: Custom values for Loki stack

## Grafana Dashboard Setup

1. After logging into Grafana, go to Configuration > Data Sources
2. Add Loki as a data source:
   - URL: `http://loki:3100`
   - Click "Save & Test"

### Importing Dashboards

We provide several pre-configured dashboards:
- Kubernetes Cluster Overview
- Node Metrics
- Pod Metrics
- Log Analytics

Import them by going to:
1. Dashboard > Import
2. Upload the JSON files from the `dashboards` directory

## Troubleshooting

Common issues and solutions:

1. If pods are stuck in Pending state:
   ```bash
   kubectl describe pod <pod-name> -n monitoring
   ```

2. Check Prometheus targets:
   ```bash
   kubectl port-forward svc/monitoring-kube-prometheus-prometheus 9090:9090 -n monitoring
   ```
   Then visit http://localhost:9090/targets

3. View Loki logs:
   ```bash
   kubectl logs -f deployment/loki -n monitoring
   ```

## Production Considerations

For production deployments:
1. Use proper storage classes for persistence
2. Configure resource limits and requests
3. Set up proper authentication
4. Configure ingress with TLS
5. Implement proper backup strategies
