# Introduction to Ingress Using Kind

## 1. Understanding Ingress

Ingress is an API object in Kubernetes that manages external access to services within a cluster. It provides HTTP and HTTPS routing to services based on rules defined in the Ingress resource.

Why use Ingress:
- Simplifies the exposure of multiple services under a single IP address
- Provides SSL/TLS termination
- Enables name-based virtual hosting and URL-based routing

## 2. Ingress Controllers

An Ingress Controller is a specialized load balancer for Kubernetes that implements the Ingress resource. It's responsible for routing HTTP and HTTPS traffic from outside the cluster to services within the cluster.

Popular Ingress Controllers:
1. Nginx Ingress Controller: Widely used, feature-rich, and maintained by the Kubernetes community
2. HAProxy Ingress Controller: Offers advanced traffic routing capabilities
3. Traefik: Auto-discovers services and integrates well with Let's Encrypt for automatic SSL
4. AWS ALB Ingress Controller: Specifically designed for AWS environments

For our Kind-based setup, we'll use the Nginx Ingress Controller due to its popularity and ease of use.

## 3. Setting up Kind for Ingress

Kind doesn't come with an Ingress Controller by default. We need to create a cluster with specific configurations to support Ingress:

1. Create a file named `kind-config.yaml` with the following content:

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
```

2. Create the Kind cluster using this configuration:

```bash
kind create cluster --config kind-config.yaml --name ingress-cluster
```

This setup creates a single-node cluster with the necessary port mappings for Ingress.

## 4. Installing Nginx Ingress Controller

After creating the cluster, install the Nginx Ingress Controller:

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/kind/deploy.yaml
```

Wait for the Ingress Controller to be ready:

```bash
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s
```

## 5. Lab: Deploying Applications Using Ingress

Now let's deploy a sample application and configure Ingress for it.

1. Create a deployment and service for a sample application:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: hello
  template:
    metadata:
      labels:
        app: hello
    spec:
      containers:
      - name: hello
        image: paulbouwer/hello-kubernetes:1.8
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: hello-service
spec:
  selector:
    app: hello
  ports:
  - port: 80
    targetPort: 8080
```

Save this as `hello-app.yaml` and apply it:

```bash
kubectl apply -f hello-app.yaml
```

2. Create an Ingress resource:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: hello-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /$2
    nginx.ingress.kubernetes.io/use-regex: "true"
spec:
  rules:
  - http:
      paths:
      - path: /hello(/|$)(.*)
        pathType: ImplementationSpecific
        backend:
          service:
            name: hello-service
            port: 
              number: 80
```

Save this as `hello-ingress.yaml` and apply it:

```bash
kubectl apply -f hello-ingress.yaml
```

3. Test the Ingress setup:

Access the application by navigating to `http://localhost/hello` in your web browser. You should see the "Hello Kubernetes!" page.

## 6. Troubleshooting

If you encounter issues:
- Check Ingress Controller logs: `kubectl logs -n ingress-nginx deployment/ingress-nginx-controller`
- Verify Ingress resource: `kubectl describe ingress hello-ingress`
- Ensure services are running: `kubectl get pods,svc`

This lab demonstrates how to set up a basic Ingress configuration in a Kind cluster. You can expand on this by adding more services, implementing path-based routing, or exploring advanced features like SSL termination and authentication.
