# StatefulSet training: Running PostgreSQL in Kubernetes

## Creating a StatefulSet
1. First, create a headless service for your deployment. A headless service is a service that defines a port binding but has its clusterIP set to None.
2. StatefulSets require you to create a headless service to control their network identities.

Use Kubectl to add the service to your cluster:

```
kubectl apply -f postgres-service.yaml
```

Apply the manifest to your cluster to create your StatefulSet:

```
kubectl apply -f postgres-statefulset.yaml
```

Now you can list the Pods running in your cluster. The names of the three Pods from your StatefulSet will be suffixed with the sequential index they’ve been assigned:

```
kubectl get pods
NAME         READY   STATUS    RESTARTS   AGE
postgres-0   1/1     Running   0          74s
postgres-1   1/1     Running   0          63s
postgres-2   1/1     Running   0          51s
```
The StatefulSet creates each Pod in order, once the previous one has entered the Running state. 
This ensures the replicas don’t start until the previous Pod is ready to synchronize data. 
If a ReplicaSet had been used, all three Pods would have been created simultaneously.

The StatefulSet uses init containers to determine whether new Pods are the Postgres primary or a replica. 
Each init container inspects its numeric index assigned by the StatefulSet controller; if it’s 0, the Pod is the first in the StatefulSet, becoming the primary database node.

Otherwise, it’s a replica:

```
kubectl logs postgres-0 -c postgres-init
I am the primary
```

```
kubectl logs postgres-1 -c postgres-init
I am a read-only replica
```

This demonstrates how StatefulSets lets you consistently designate Pods as having a specific role. 

### Let's look on the StatefulSet Persistent Volume and Persistent Volume Claim.

```
kubectl get pv
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                          STORAGECLASS   REASON   AGE
pvc-4dfjkhg4-0722-4666-aea9-12e0960f732e   1Gi        RWO            Delete           Bound    postgres-sts/data-postgres-0   standard                10m
pvc-45fdjfjh-4567-454e-83e8-2c2f4c80af07   1Gi        RWO            Delete           Bound    postgres-sts/data-postgres-1   standard                10m
pvc-dh33h33d-66j6-405b-bf95-b28bf9bcedec   1Gi        RWO            Delete           Bound    postgres-sts/data-postgres-2   standard                10m
```

```
kubectl get pvc
NAME              STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
data-postgres-0   Bound    pvc-4dfjkhg4-0722-4666-aea9-12e0960f732e   1Gi        RWO            standard       10m
data-postgres-1   Bound    pvc-45fdjfjh-4567-454e-83e8-2c2f4c80af07   1Gi        RWO            standard       10m
data-postgres-2   Bound    pvc-dh33h33d-66j6-405b-bf95-b28bf9bcedec   1Gi        RWO            standard       10m
```
This allows the Pods to manage their own state, independently of the others in the StatefulSet.

