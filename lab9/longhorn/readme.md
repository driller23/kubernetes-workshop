# Longhorn Storage Lab with Kind Cluster

This lab guides you through setting up Longhorn storage system in a Kind (Kubernetes IN Docker) cluster.

## Prerequisites

- Docker installed
- Kind installed
- kubectl installed
- Helm v3 installed

## Lab Steps

### 1. Create Kind Cluster with Extra Mounts

First, create a Kind cluster configuration file `kind-config.yaml`:

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraMounts:
  - hostPath: /tmp/longhorn-storage
    containerPath: /var/lib/longhorn
- role: worker
  extraMounts:
  - hostPath: /tmp/longhorn-storage-worker1
    containerPath: /var/lib/longhorn
- role: worker
  extraMounts:
  - hostPath: /tmp/longhorn-storage-worker2
    containerPath: /var/lib/longhorn
```

Create the directories for storage:
```bash
sudo mkdir -p /tmp/longhorn-storage
sudo mkdir -p /tmp/longhorn-storage-worker1
sudo mkdir -p /tmp/longhorn-storage-worker2
sudo chmod 777 /tmp/longhorn-storage*
```

Create the cluster:
```bash
kind create cluster --name longhorn-test --config kind-config.yaml
```

### 2. Install Required Dependencies

Install open-iscsi in the Kind nodes:
```bash
for node in $(kind get nodes --name longhorn-test); do
  docker exec $node apt-get update
  docker exec $node apt-get install -y open-iscsi
  docker exec $node systemctl enable iscsid
  docker exec $node systemctl start iscsid
done
```

### 3. Install Longhorn

Add the Longhorn Helm repository:
```bash
helm repo add longhorn https://charts.longhorn.io
helm repo update
```

Create longhorn namespace:
```bash
kubectl create namespace longhorn-system
```

Install Longhorn:
```bash
helm install longhorn longhorn/longhorn \
  --namespace longhorn-system \
  --set defaultSettings.defaultReplicaCount=2 \
  --set defaultSettings.createDefaultDiskLabeledNodes=true
```

Verify the installation:
```bash
kubectl -n longhorn-system get pods
```

### 4. Access Longhorn UI

Create port-forward to access the Longhorn UI:
```bash
kubectl port-forward -n longhorn-system service/longhorn-frontend 8000:80
```

Access the UI at http://localhost:8000

### 5. Test Storage with Demo Application

Create a PVC (test-pvc.yaml):
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: test-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: longhorn
  resources:
    requests:
      storage: 1Gi
```

Create a test pod (test-pod.yaml):
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-pod
spec:
  containers:
  - name: test-pod
    image: nginx
    volumeMounts:
    - name: test-vol
      mountPath: /usr/share/nginx/html
  volumes:
  - name: test-vol
    persistentVolumeClaim:
      claimName: test-pvc
```

Apply the configurations:
```bash
kubectl apply -f test-pvc.yaml
kubectl apply -f test-pod.yaml
```

### 6. Verify Storage Functionality

Write test data:
```bash
kubectl exec -it test-pod -- /bin/bash -c "echo 'Hello Longhorn' > /usr/share/nginx/html/test.txt"
```

Verify data persistence:
```bash
# Delete the pod
kubectl delete pod test-pod

# Recreate the pod
kubectl apply -f test-pod.yaml

# Verify data still exists
kubectl exec -it test-pod -- cat /usr/share/nginx/html/test.txt
```

## Troubleshooting

### Common Issues in Kind Environment

1. If pods are stuck in ContainerCreating state:
```bash
kubectl describe pod <pod-name>
kubectl -n longhorn-system logs -l app=longhorn-manager
```

2. If volume mounting fails:
```bash
# Check iscsi status in nodes
for node in $(kind get nodes --name longhorn-test); do
  echo "Checking $node..."
  docker exec $node systemctl status iscsid
done
```

3. If Longhorn UI is not accessible:
```bash
kubectl -n longhorn-system get svc
kubectl -n longhorn-system describe svc longhorn-frontend
```

### Clean Up

Delete the test resources:
```bash
kubectl delete pod test-pod
kubectl delete pvc test-pvc
```

Delete the entire Kind cluster:
```bash
kind delete cluster --name longhorn-test
```

Clean up storage directories:
```bash
sudo rm -rf /tmp/longhorn-storage*
```

## Additional Files

### kind-config.yaml
```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraMounts:
  - hostPath: /tmp/longhorn-storage
    containerPath: /var/lib/longhorn
- role: worker
  extraMounts:
  - hostPath: /tmp/longhorn-storage-worker1
    containerPath: /var/lib/longhorn
- role: worker
  extraMounts:
  - hostPath: /tmp/longhorn-storage-worker2
    containerPath: /var/lib/longhorn
```

### setup-scripts/install-dependencies.sh
```bash
#!/bin/bash

# Create storage directories
sudo mkdir -p /tmp/longhorn-storage
sudo mkdir -p /tmp/longhorn-storage-worker1
sudo mkdir -p /tmp/longhorn-storage-worker2
sudo chmod 777 /tmp/longhorn-storage*

# Install iscsi on all nodes
for node in $(kind get nodes --name longhorn-test); do
  echo "Installing dependencies on $node..."
  docker exec $node apt-get update
  docker exec $node apt-get install -y open-iscsi
  docker exec $node systemctl enable iscsid
  docker exec $node systemctl start iscsid
done
```

### test-pvc.yaml
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: test-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: longhorn
  resources:
    requests:
      storage: 1Gi
```

### test-pod.yaml
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-pod
spec:
  containers:
  - name: test-pod
    image: nginx
    volumeMounts:
    - name: test-vol
      mountPath: /usr/share/nginx/html
  volumes:
  - name: test-vol
    persistentVolumeClaim:
      claimName: test-pvc
```

## Best Practices for Kind + Longhorn

1. Always use multiple worker nodes for proper replica distribution
2. Ensure sufficient storage space in host directories
3. Monitor node resource usage as Kind runs in containers
4. Use node affinity rules for production workloads
5. Regular backup of important data
6. Test failover scenarios by stopping/starting Kind nodes

Would you like me to create additional configuration files or scripts for any specific part of the lab?
