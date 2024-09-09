# Kind Demo: Deep Dive into Namespaces, Pods, and RBAC

This demo will focus on working with namespaces, pods, and RBAC in a Kind cluster.

## 1. Set up Kind cluster

First, let's create a Kind cluster:

```bash
kind create cluster --name namespace-demo
```

## 2. Create Namespaces

We'll create two namespaces for our demo:

```bash
kubectl create namespace development
kubectl create namespace production
```

Verify the namespaces:

```bash
kubectl get namespaces
```

## 3. Deploy Pods to Namespaces

Let's deploy some pods to each namespace:

For development:
```bash
kubectl run dev-pod-1 --image=nginx -n development
kubectl run dev-pod-2 --image=busybox -n development -- sleep 3600
```

For production:
```bash
kubectl run prod-pod-1 --image=nginx -n production
kubectl run prod-pod-2 --image=busybox -n production -- sleep 3600
```

Verify the pods in each namespace:

```bash
kubectl get pods -n development
kubectl get pods -n production
```

## 4. Create Services

Let's create services for our nginx pods:

For development:
```bash
kubectl expose pod dev-pod-1 --port=80 --name=dev-service -n development
```

For production:
```bash
kubectl expose pod prod-pod-1 --port=80 --name=prod-service -n production
```

Verify the services:

```bash
kubectl get services -n development
kubectl get services -n production
```

## 5. Namespace Resource Quotas

We can set resource quotas for namespaces:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ResourceQuota
metadata:
  name: dev-quota
  namespace: development
spec:
  hard:
    pods: "5"
    requests.cpu: "1"
    requests.memory: 1Gi
    limits.cpu: "2"
    limits.memory: 2Gi
EOF
```

Check the quota:

```bash
kubectl describe quota -n development
```

## confront the quota 

run this:

```
./quota.sh
```

## 6. RBAC Setup

Now, let's set up RBAC for our namespaces:

Create a development-user:
```bash
kubectl create serviceaccount dev-user -n development
```

Create a role that allows reading pods and services:
```bash
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: development
  name: pod-and-services-reader
rules:
- apiGroups: [""]
  resources: ["pods", "services"]
  verbs: ["get", "list", "watch"]
EOF
```

Bind the role to the dev-user:
```bash
kubectl create rolebinding dev-user-binding --role=pod-and-services-reader --serviceaccount=development:dev-user -n development
```

## 7. Testing RBAC

To test our RBAC setup, we'll use kubectl with the dev-user's permissions:

First, get the token for dev-user:
```bash
DEV_USER_TOKEN=$(kubectl -n development create token dev-user)
```

Now, test accessing resources:

```bash
# This should work
kubectl --token=$DEV_USER_TOKEN get pods -n development

# This should work
kubectl --token=$DEV_USER_TOKEN get services -n development

# This should fail
kubectl --token=$DEV_USER_TOKEN create pod test-pod --image=nginx -n development

# This should fail
kubectl --token=$DEV_USER_TOKEN get pods -n production
```

## 8. Namespace Isolation

Demonstrate namespace isolation by trying to access a service from a different namespace:

```bash
# Create a temporary pod in the development namespace
kubectl run tmp-pod --image=busybox -n development -- sleep 3600

# Try to access the production service from the development namespace
kubectl exec -it tmp-pod -n development -- wget -O- prod-service.production.svc.cluster.local

# This should fail, demonstrating namespace isolation
```

## 9. Cross-Namespace Communication (Optional)

If you want to allow cross-namespace communication:

```bash
# Create a service with type ClusterIP in production namespace
kubectl expose pod prod-pod-1 --port=80 --name=prod-cluster-service -n production --type=ClusterIP

# Now try to access it from the development namespace
kubectl exec -it tmp-pod -n development -- wget -O- prod-cluster-service.production.svc.cluster.local

# This should work, allowing controlled cross-namespace communication
```

## Cleanup

To delete the Kind cluster and clean up:

```bash
kind delete cluster --name namespace-demo
```

This demo provides a deep dive into working with namespaces in Kind, including creating and managing pods and services within namespaces, setting up basic RBAC, and demonstrating namespace isolation and cross-namespace communication.
