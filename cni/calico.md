# Create cluster 
```kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
  disableDefaultCNI: true
  podSubnet: "192.168.0.0/16"
```

```kind create cluster --config kind-config.yaml```

## Verify that the cluster is created:
```kubectl get nodes```
The nodes should be in "NotReady" state because there's no CNI yet.

## Install the Calico operator:
```kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/tigera-operator.yaml```

## Install Calico custom resources:
```kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/custom-resources.yaml```

## Wait for Calico to be ready. This might take a few minutes:
```kubectl wait --namespace calico-system --for=condition=ready pod --all --timeout=90s```

## Verify that all Calico pods are running:
```kubectl get pods -n calico-system```

## Check the node status again:
```kubectl get nodes```
The nodes should now be in "Ready" state.

## Finally, test your cluster by deploying a simple application:

```kubectl create deployment nginx --image=nginx```

```kubectl expose deployment nginx --port=80```
kubectl get pods
You should see the nginx pod running.
