# Managing Longhorn Storage and PostgreSQL in Kind

This guide demonstrates how to set up Longhorn storage system and PostgreSQL clusters in a Kind (Kubernetes in Docker) environment.

## Prerequisites

- Docker installed and running
- kubectl CLI tool
- Helm v3
- Kind installed

## 1. Creating the Kind Cluster

First, we'll create a Kind cluster with the proper configuration for Longhorn:

```bash
# Create directory for cluster configuration
mkdir kind-cluster && cd kind-cluster
```

Save the following configuration as `kind-config.yaml` and apply it:

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraMounts:
  - hostPath: ./storage
    containerPath: /storage
- role: worker
  extraMounts:
  - hostPath: ./storage
    containerPath: /storage
- role: worker
  extraMounts:
  - hostPath: ./storage
    containerPath: /storage
```

Create the cluster:
```bash
mkdir storage
kind create cluster --name storage-cluster --config kind-config.yaml
```

## 2. Installing Longhorn

1. Add the Longhorn Helm repository:
```bash
helm repo add longhorn https://charts.longhorn.io
helm repo update
```

2. Install Longhorn:
```bash
helm install longhorn longhorn/longhorn \
  --namespace longhorn-system \
  --create-namespace \
  --values longhorn-values.yaml
```

3. Verify the installation:
```bash
kubectl -n longhorn-system get pods
```

## 3. Setting up PostgreSQL Operator

We'll use the Zalando PostgreSQL Operator for managing PostgreSQL clusters.

1. Add the PostgreSQL Operator repository:
```bash
helm repo add postgres-operator https://opensource.zalando.com/postgres-operator/charts/postgres-operator
helm repo update
```

2. Install the PostgreSQL Operator:
```bash
helm install postgres-operator postgres-operator/postgres-operator \
  --namespace postgres-operator \
  --create-namespace \
  --values postgres-operator-values.yaml
```

3. Verify the operator installation:
```bash
kubectl -n postgres-operator get pods
```

## 4. Creating a PostgreSQL Cluster

1. Create a PostgreSQL cluster by applying the following manifest:

```bash
kubectl apply -f postgres-cluster.yaml
```

2. Monitor the cluster creation:
```bash
kubectl get postgresql
kubectl get pods -l application=spilo -L spilo-role
```

## Storage Configuration

### Longhorn Storage Class

Monitor Longhorn storage:
```bash
kubectl -n longhorn-system get storageclass
kubectl -n longhorn-system get pv
kubectl -n longhorn-system get pvc
```

### Volume Snapshots

Create a volume snapshot:
```bash
kubectl apply -f volume-snapshot.yaml
```

## Example Configurations

### PostgreSQL Cluster Configuration
```yaml
apiVersion: "acid.zalan.do/v1"
kind: postgresql
metadata:
  name: my-postgres-cluster
spec:
  teamId: "myteam"
  volume:
    size: 5Gi
    storageClass: longhorn
  numberOfInstances: 3
  users:
    myapp: []  # database owner
  databases:
    myapp: myapp  # dbname: owner
  postgresql:
    version: "15"
    parameters:
      shared_buffers: "32MB"
      max_connections: "100"
      log_statement: "all"
```

### Backup Configuration
```yaml
apiVersion: "acid.zalan.do/v1"
kind: postgresql
metadata:
  name: my-postgres-cluster
spec:
  # ... other configurations ...
  backup:
    schedule: "0 0 * * *"  # daily backup at midnight
    volume:
      storageClass: longhorn
    retention: 14
```

## Monitoring and Management

### Check Cluster Status
```bash
# Get cluster status
kubectl get postgresql

# Get pod status
kubectl get pods -l application=spilo

# Get service status
kubectl get svc -l application=spilo
```

### Access Database

1. Get the password for the postgres user:
```bash
kubectl get secret postgres.my-postgres-cluster.credentials \
  -o 'jsonpath={.data.password}' | base64 -d
```

2. Port forward the master service:
```bash
kubectl port-forward svc/my-postgres-cluster 5432:5432
```

3. Connect using psql:
```bash
psql -h localhost -p 5432 -U postgres
```

## Maintenance Tasks

### Scaling the Cluster

Update the number of instances:
```bash
kubectl patch postgresql my-postgres-cluster --type merge \
  -p '{"spec":{"numberOfInstances":5}}'
```

### Update PostgreSQL Version

Update the PostgreSQL version:
```bash
kubectl patch postgresql my-postgres-cluster --type merge \
  -p '{"spec":{"postgresql":{"version":"15"}}}'
```

## Troubleshooting

Common issues and solutions:

1. Pods stuck in Pending state:
```bash
kubectl describe pod <pod-name>
```

2. Check operator logs:
```bash
kubectl logs -n postgres-operator deployment/postgres-operator
```

3. Check Longhorn controller logs:
```bash
kubectl -n longhorn-system logs -l app=longhorn-manager
```

## Clean Up

Remove everything:
```bash
# Delete PostgreSQL cluster
kubectl delete postgresql my-postgres-cluster

# Uninstall operators
helm uninstall postgres-operator -n postgres-operator
helm uninstall longhorn -n longhorn-system

# Delete namespaces
kubectl delete namespace postgres-operator
kubectl delete namespace longhorn-system

# Delete Kind cluster
kind delete cluster --name storage-cluster
```
