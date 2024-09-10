# ConfigMap

apply yaml

```
kubectl apply -f demo-config.yaml
```

## get configmap
```kubectl get configmaps```

OR inspect
```
kubectl describe configmap demo-config
```

OR
```kubectl get configmap demo-config -o jsonpath='{.data}' | jq```
