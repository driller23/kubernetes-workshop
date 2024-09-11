# Install Kind Cluster 

## MacOs 

```brew install kind```

Explanation: Uses Homebrew package manager to install kind

## Linux

```
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.11.1/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
```

Downloads the kind binary
Makes it executable
Moves it to a directory in the system PATH

## Windows

```
choco install kind
```

# install Kubectl 

## macOS

```
brew install kubectl
```

Explanation: Uses Homebrew to install kubectl

## Linux
```
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

Explanation:
Downloads the latest stable kubectl binary
Installs it with the correct permissions in /usr/local/bin

## Windows

```
choco install kubernetes-cli
```

# Create a kind cluster:
kind create cluster --name my-web-app

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
