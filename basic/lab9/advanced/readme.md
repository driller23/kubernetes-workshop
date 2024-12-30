# Kubernetes Persistent Storage Lab

This lab provides hands-on experience with Kubernetes persistent storage concepts including PersistentVolumes (PV), PersistentVolumeClaims (PVC), and StorageClasses.

## Prerequisites

- Kubernetes cluster (minikube, kind, or any other Kubernetes cluster)
- kubectl CLI tool installed
- Basic understanding of Kubernetes concepts

## Lab Objectives

1. Create a PersistentVolume
2. Create a PersistentVolumeClaim
3. Create a Pod that uses the PVC
4. Test data persistence
5. Understand StorageClass usage

## Lab Steps

### 1. Create a PersistentVolume

First, we'll create a PersistentVolume that uses hostPath storage (for learning purposes - not recommended for production).

Create `pv.yaml`:

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: task-pv
spec:
  capacity:
    storage: 1Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: manual
  hostPath:
    path: "/mnt/data"
```

Apply the configuration:
```bash
kubectl apply -f pv.yaml
```

Verify the PV was created:
```bash
kubectl get pv
```

### 2. Create a PersistentVolumeClaim

Create `pvc.yaml`:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: task-pvc
spec:
  accessModes:
    - ReadWriteOnce
  volumeMode: Filesystem
  resources:
    requests:
      storage: 1Gi
  storageClassName: manual
```

Apply the configuration:
```bash
kubectl apply -f pvc.yaml
```

Verify the PVC was created and bound to the PV:
```bash
kubectl get pvc
```

### 3. Create a Pod Using the PVC

Create `pod.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: task-pod
spec:
  containers:
    - name: task-container
      image: nginx
      volumeMounts:
        - mountPath: "/usr/share/nginx/html"
          name: task-volume
  volumes:
    - name: task-volume
      persistentVolumeClaim:
        claimName: task-pvc
```

Apply the configuration:
```bash
kubectl apply -f pod.yaml
```

### 4. Test Data Persistence

1. Create some data in the mounted volume:
```bash
kubectl exec -it task-pod -- /bin/bash
echo "Hello from Kubernetes Storage" > /usr/share/nginx/html/index.html
exit
```

2. Delete the pod:
```bash
kubectl delete pod task-pod
```

3. Recreate the pod:
```bash
kubectl apply -f pod.yaml
```

4. Verify the data persists:
```bash
kubectl exec -it task-pod -- cat /usr/share/nginx/html/index.html
```

### 5. Explore StorageClass (Optional)

Create `storageclass.yaml`:

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: standard
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
```

Apply the configuration:
```bash
kubectl apply -f storageclass.yaml
```

## Cleanup

Delete all resources created in this lab:

```bash
kubectl delete pod task-pod
kubectl delete pvc task-pvc
kubectl delete pv task-pv
kubectl delete storageclass standard
```

## Key Learning Points

1. PersistentVolumes provide a way to store data that persists beyond the lifecycle of a pod
2. PersistentVolumeClaims are used by pods to request storage resources
3. StorageClasses enable dynamic provisioning of storage resources
4. Data persists even when pods are deleted and recreated
5. Different access modes and reclaim policies affect how storage can be used

## Common Issues and Troubleshooting

1. If PVC remains in "Pending" state:
   - Check if PV is available
   - Verify storage class names match
   - Ensure access modes are compatible
   
2. If Pod can't mount volume:
   - Verify PVC is bound to PV
   - Check volume mount paths
   - Review pod events: `kubectl describe pod <pod-name>`

## Best Practices

1. Always specify resource requests and limits
2. Use appropriate access modes based on your needs
3. Consider using StorageClasses for dynamic provisioning
4. Implement proper backup strategies
5. Monitor storage usage and capacity

## Additional Resources

- [Kubernetes Storage Documentation](https://kubernetes.io/docs/concepts/storage/)
- [Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)
- [Storage Classes](https://kubernetes.io/docs/concepts/storage/storage-classes/)
