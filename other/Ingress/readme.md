# Step 1: Create a kind cluster with extraPortMappings and node-labels

```
kind create cluster --config kind-config.yaml
```

# Step 2: Install NGINX Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

## Wait for the Ingress controller to be ready
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s

# Step 3: Create a sample application

```
kubectl apply -f sample-app.yaml
```

# Step 4: Create an Ingress resource

```
kubectl apply -f ingress.yaml
```

# Step 5: Verify the setup
```
kubectl get pods -A
kubectl get ingress
kubectl get services -A
```

# Step 6: Test the application
```
curl http://localhost/hello
```
