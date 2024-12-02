# 1. First, create a kind cluster configuration

---
# 2. MetalLB Installation and Configuration
# metallb-config.yaml

```
apiVersion: v1
kind: Namespace
metadata:
  name: metallb-system
---
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: first-pool
  namespace: metallb-system
spec:
  addresses:
  - 172.18.255.200-172.18.255.250  # Adjust this range based on your kind network
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: l2-advert
  namespace: metallb-system
spec:
  ipAddressPools:
  - first-pool
```
---
# 3. Example Application Deployment
# app-deployment.yaml
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
          name: http
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 10
```
---
# 4. LoadBalancer Service
# loadbalancer-service.yaml
```
apiVersion: v1
kind: Service
metadata:
  name: nginx-loadbalancer
spec:
  type: LoadBalancer
  ports:
  - name: http
    port: 80
    targetPort: 80
    protocol: TCP
  selector:
    app: nginx
```
## Save the kind config to kind-config.yaml and create cluster
```
kind create cluster --config kind-config.yaml
```
## Apply MetalLB manifests
```
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.12/config/manifests/metallb-native.yaml
```
## Wait for MetalLB pods to be ready
```
kubectl wait --namespace metallb-system \
                --for=condition=ready pod \
                --selector=app=metallb \
                --timeout=90s
```
## Apply the MetalLB configuration
```
kubectl apply -f metallb-config.yaml
```

## Deploy the application and service:

```
kubectl apply -f app-deployment.yaml
kubectl apply -f loadbalancer-service.yaml
```

## Verify the LoadBalancer service:

```
kubectl get svc nginx-loadbalancer
```
