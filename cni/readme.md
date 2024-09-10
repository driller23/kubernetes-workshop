# Step 1: Install kind
```
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.11.1/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
```

# Step 2: Create a kind cluster configuration

```
cat <<EOF > kind-config.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
- role: worker
networking:
  disableDefaultCNI: true
EOF
```

# Step 3: Create the kind cluster
```
kind create cluster --config kind-config.yaml
```

# Step 4: Install Cilium CLI
```
curl -L --remote-name-all https://github.com/cilium/cilium-cli/releases/latest/download/cilium-linux-amd64.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-amd64.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-amd64.tar.gz /usr/local/bin
rm cilium-linux-amd64.tar.gz{,.sha256sum}
```

# Step 5: Install Cilium
```
cilium install
```

# Step 6: Verify Cilium installation
```
cilium status --wait
```

# Step 7: Run connectivity test
```
cilium connectivity test
```

# Step 8: Deploy a sample application
```
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80
```

# Step 9: Verify the deployment

```
kubectl get pods -o wide
kubectl get services
```

# Step 10: Test network connectivity

```
kubectl run busybox --rm -ti --image=busybox -- wget -O- http://nginx
```
