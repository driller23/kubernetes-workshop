# PostgreSQL StatefulSet in Kubernetes

This guide demonstrates how to run PostgreSQL in Kubernetes using StatefulSets, creating a cluster with one primary and multiple read replicas.

## Prerequisites

- Kubernetes cluster
- kubectl configured
- Storage class supporting ReadWriteOnce (RWO) access mode

## Components

1. Headless Service for network identity
2. StatefulSet with three PostgreSQL replicas
3. Persistent storage for each Pod
4. Init containers for role determination

## Deployment

### 1. Create the Headless Service

Create `postgres-service.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: postgres
  labels:
    app: postgres
spec:
  ports:
    - name: postgres
      port: 5432
  clusterIP: None
  selector:
    app: postgres
```

Apply the service:
```bash
kubectl apply -f postgres-service.yaml
```

### 2. Create the StatefulSet

Create `postgres-statefulset.yaml`:

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
spec:
  selector:
    matchLabels:
      app: postgres
  serviceName: postgres
  replicas: 3
  template:
    metadata:
      labels:
        app: postgres
    spec:
      initContainers:
        - name: postgres-init
          image: postgres:latest
          command:
          - bash
          - "-c"
          - |
            set -ex
            [[ `hostname` =~ -([0-9]+)$ ]] || exit 1
            ordinal=${BASH_REMATCH[1]}
            if [[ $ordinal -eq 0 ]]; then
              printf "I am the primary"
            else
              printf "I am a read-only replica"
            fi
      containers:
        - name: postgres
          image: postgres:latest
          env:
            - name: POSTGRES_USER
              value: postgres
            - name: POSTGRES_PASSWORD
              value: postgres
            - name: POD_IP
              valueFrom:
                fieldRef:
                  apiVersion: v1
                  fieldPath: status.podIP
          ports:
          - name: postgres
            containerPort: 5432
          livenessProbe:
            exec:
              command:
                - "sh"
                - "-c"
                - "pg_isready --host $POD_IP"
            initialDelaySeconds: 30
            periodSeconds: 5
            timeoutSeconds: 5
          readinessProbe:
            exec:
              command:
                - "sh"
                - "-c"
                - "pg_isready --host $POD_IP"
            initialDelaySeconds: 5
            periodSeconds: 5
            timeoutSeconds: 1
          volumeMounts:
          - name: data
            mountPath: /var/lib/postgresql/data
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 1Gi
```

Apply the StatefulSet:
```bash
kubectl apply -f postgres-statefulset.yaml
```

## Verification

### 1. Check Pod Status
```bash
kubectl get pods
```

Expected output:
```
NAME         READY   STATUS    RESTARTS   AGE
postgres-0   1/1     Running   0          74s
postgres-1   1/1     Running   0          63s
postgres-2   1/1     Running   0          51s
```

### 2. Verify Role Assignment

Check primary:
```bash
kubectl logs postgres-0 -c postgres-init
```

Check replica:
```bash
kubectl logs postgres-1 -c postgres-init
```

### 3. Verify Storage

Check Persistent Volumes:
```bash
kubectl get pv
```

Check Persistent Volume Claims:
```bash
kubectl get pvc
```

## Key Features

1. **Ordered Pod Creation**
   - Pods are created sequentially
   - Each pod waits for the previous to be ready

2. **Stable Network Identity**
   - Each pod gets a predictable hostname
   - Headless service manages network identity

3. **Role Assignment**
   - postgres-0: Primary database
   - postgres-[1,2]: Read replicas

4. **Persistent Storage**
   - Each pod gets its own persistent volume
   - Data survives pod restarts

## Best Practices

1. **Storage**
   - Use appropriate storage class
   - Ensure sufficient storage capacity
   - Consider backup strategy

2. **Security**
   - Don't use hardcoded credentials in production
   - Use Kubernetes Secrets
   - Implement network policies

3. **Monitoring**
   - Set appropriate probe values
   - Monitor replication lag
   - Track disk usage

## Cleanup

Remove the StatefulSet and Service:
```bash
kubectl delete -f postgres-statefulset.yaml
kubectl delete -f postgres-service.yaml
```

## Contributing

Feel free to submit issues and enhancement requests!

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
