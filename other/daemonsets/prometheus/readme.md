To install Prometheus and Grafana with exporters as DaemonSets on a kind Kubernetes cluster without using Helm, we'll need to create and apply several Kubernetes manifests. I'll guide you through the process step-by-step.

1. First, let's create a namespace for our monitoring stack:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: monitoring
```

Save this as `namespace.yaml` and apply it:

```
kubectl apply -f namespace.yaml
```

2. Now, let's create a ConfigMap for Prometheus:



```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
  namespace: monitoring
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
    scrape_configs:
      - job_name: 'kubernetes-nodes'
        kubernetes_sd_configs:
        - role: node
        relabel_configs:
        - source_labels: [__address__]
          regex: '(.*):10250'
          replacement: '${1}:9100'
          target_label: __address__
          action: replace
      - job_name: 'kubernetes-pods'
        kubernetes_sd_configs:
        - role: pod
        relabel_configs:
        - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
          action: keep
          regex: true
        - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
          action: replace
          target_label: __metrics_path__
          regex: (.+)
        - source_labels: [__address__, __meta_kubernetes_pod_annotation_prometheus_io_port]
          action: replace
          regex: ([^:]+)(?::\d+)?;(\d+)
          replacement: $1:$2
          target_label: __address__

```

Save this as `prometheus-config.yaml` and apply it:

```
kubectl apply -f prometheus-config.yaml
```

3. Next, let's create a Prometheus deployment:



```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: prometheus
  namespace: monitoring
spec:
  replicas: 1
  selector:
    matchLabels:
      app: prometheus
  template:
    metadata:
      labels:
        app: prometheus
    spec:
      containers:
      - name: prometheus
        image: prom/prometheus
        args:
        - "--config.file=/etc/prometheus/prometheus.yml"
        ports:
        - containerPort: 9090
        volumeMounts:
        - name: config
          mountPath: /etc/prometheus
      volumes:
      - name: config
        configMap:
          name: prometheus-config
---
apiVersion: v1
kind: Service
metadata:
  name: prometheus
  namespace: monitoring
spec:
  selector:
    app: prometheus
  ports:
  - port: 9090
    targetPort: 9090

```

Save this as `prometheus-deployment.yaml` and apply it:

```
kubectl apply -f prometheus-deployment.yaml
```

4. Now, let's create a DaemonSet for the node-exporter:



```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-exporter
  namespace: monitoring
spec:
  selector:
    matchLabels:
      app: node-exporter
  template:
    metadata:
      labels:
        app: node-exporter
    spec:
      hostNetwork: true
      hostPID: true
      containers:
      - name: node-exporter
        image: prom/node-exporter
        args:
        - "--path.procfs=/host/proc"
        - "--path.sysfs=/host/sys"
        ports:
        - containerPort: 9100
        volumeMounts:
        - name: proc
          mountPath: /host/proc
          readOnly: true
        - name: sys
          mountPath: /host/sys
          readOnly: true
      volumes:
      - name: proc
        hostPath:
          path: /proc
      - name: sys
        hostPath:
          path: /sys

```

Save this as `node-exporter-daemonset.yaml` and apply it:

```
kubectl apply -f node-exporter-daemonset.yaml
```

5. For Grafana, let's create a deployment:



```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: grafana
  namespace: monitoring
spec:
  replicas: 1
  selector:
    matchLabels:
      app: grafana
  template:
    metadata:
      labels:
        app: grafana
    spec:
      containers:
      - name: grafana
        image: grafana/grafana
        ports:
        - containerPort: 3000
        env:
        - name: GF_SECURITY_ADMIN_PASSWORD
          value: "admin"  # Change this to a secure password
---
apiVersion: v1
kind: Service
metadata:
  name: grafana
  namespace: monitoring
spec:
  selector:
    app: grafana
  ports:
  - port: 3000
    targetPort: 3000

```

Save this as `grafana-deployment.yaml` and apply it:

```
kubectl apply -f grafana-deployment.yaml
```

Now you have Prometheus and Grafana installed on your kind Kubernetes cluster with the node-exporter running as a DaemonSet. To access these services:

1. For Prometheus:
   ```
   kubectl port-forward -n monitoring svc/prometheus 9090:9090
   ```
   Then access it at http://localhost:9090

2. For Grafana:
   ```
   kubectl port-forward -n monitoring svc/grafana 3000:3000
   ```
   Then access it at http://localhost:3000 (default credentials are admin/admin)

Remember to configure Grafana to use Prometheus as a data source and set up your dashboards.

Would you like me to explain any part of this setup in more detail?
