# Ghost Blog Deployment Guide

This guide demonstrates how to deploy a Ghost blog using Docker and Kubernetes with Helm, including both development and production configurations.

## Table of Contents
- [Simple Docker Deployment](#simple-docker-deployment)
- [Kubernetes Deployment](#kubernetes-deployment)
- [Helm Chart Deployment](#helm-chart-deployment)
- [Multi-Environment Configuration](#multi-environment-configuration)

## Simple Docker Deployment

Deploy Ghost using Docker:

```bash
docker run --rm -p 2368:2368 --name my-ghost ghost
```

Access the blog at: http://localhost:2368

Stop the container:
```bash
docker rm -f my-ghost
```

## Kubernetes Deployment

### Basic Deployment

1. Create `deployment.yaml`:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ghost-app
spec:
  selector:
    matchLabels:
      app: ghost-app
  replicas: 2
  template:
    metadata:
      labels:
        app: ghost-app
    spec:
      containers:
        - name: ghost-app
          image: ghost
          ports:
            - containerPort: 2368
```

2. Create `service.yaml`:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service-for-ghost-app
spec:
  type: LoadBalancer
  selector:
    app: ghost-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 2368
```

3. Deploy:
```bash
kubectl apply -f ./application/deployment.yaml -f ./application/service.yaml
```

## Helm Chart Deployment

1. Create a new Helm chart:
```bash
helm create my-ghost-app
```

2. Required files structure:
```
my-ghost-app/
├── Chart.yaml
├── templates/
│   ├── deployment.yaml
│   └── service.yaml
└── values.yaml
```

### Chart Configuration

1. `Chart.yaml`:
```yaml
apiVersion: v2
name: my-ghost-app
description: A Helm chart for Kubernetes
type: application
version: 0.1.0
appVersion: 1.16.0
```

2. `templates/deployment.yaml`:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ghost-app
spec:
  selector:
    matchLabels:
      app: ghost-app
  replicas: {{ .Values.replicaCount }}
  template:
    metadata:
      labels:
        app: ghost-app
    spec:
      containers:
        - name: ghost-app
          image: ghost
          ports:
            - containerPort: 2368
          env:
            - name: url
              {{- if .Values.prodUrlSchema }}
              value: http://{{ .Values.baseUrl }}
              {{- else }}
              value: http://{{ .Values.datacenter }}.non-prod.{{ .Values.baseUrl }}
              {{- end }}
```

3. `values.yaml`:
```yaml
replicaCount: 1
prodUrlSchema: false
datacenter: us-east
baseUrl: myapp.org
```

## Multi-Environment Configuration

### Environment-specific Values Files

1. Datacenter configurations:
```yaml
# values.us-east.yaml
datacenter: us-east

# values.us-west.yaml
datacenter: us-west
```

2. Stage configurations:
```yaml
# values.nonprod.yaml
replicaCount: 1
prodUrlSchema: false

# values.prod.yaml
replicaCount: 3
prodUrlSchema: true
```

### Deployment Examples

1. Test configuration:
```bash
helm template --debug my-ghost-app -f values.nonprod.yaml -f values.us-east.yaml
```

2. Production deployment:
```bash
helm install -f values.prod.yaml my-ghost-prod ./my-ghost-app/
```

3. Non-prod deployment:
```bash
helm install -f values.nonprod.yaml -f values.us-east.yaml my-ghost-nonprod ./my-ghost-app
```

### Cleanup

Remove deployments:
```bash
helm delete my-ghost-prod
# or
helm delete my-ghost-nonprod
```

## Best Practices

1. Always start with default values in `values.yaml`
2. Use environment-specific value files for overrides
3. Test configurations using `helm template` before deployment
4. Maintain separate value files for different environments
5. Use meaningful naming conventions for releases
