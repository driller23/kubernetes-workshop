# Create a kind cluster:
bashCopykind create cluster --name my-web-app

## Write a Deployment YAML (web-app-deployment.yaml):

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
      - name: web-app
        image: nginx:latest
        ports:
        - containerPort: 80
```

Write a Service YAML (web-app-service.yaml):

```
apiVersion: v1
kind: Service
metadata:
  name: web-app-service
spec:
  selector:
    app: web-app
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
  type: LoadBalancer
```

## Apply the YAML files:

```
kubectl apply -f web-app-deployment.yaml
kubectl apply -f web-app-service.yaml
```
## Verify the deployment:
```
kubectl get deployments
kubectl get pods
kubectl get services
```
## Access the application:
```
kubectl port-forward service/web-app-service 8080:80
```
