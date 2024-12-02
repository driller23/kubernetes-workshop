## Run the kind config to kind-config.yaml and create cluster
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
