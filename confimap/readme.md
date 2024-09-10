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

## envForm example
```kubectl apply -f demo-pod.yaml```

# config immutable

```
kubectl apply -f demo-config-immutable.yaml
configmap/demo-config-immutable created
```
Now try changing the ConfigMap, such as by changing foo from bar to baz:

```
data:
  foo: baz
```
When you re-apply the manifest, you’ll see a Forbidden error because the immutable ConfigMap doesn’t permit modifications:

```
kubectl apply -f demo-config-immutable.yaml
The ConfigMap "demo-config-immutable" is invalid: data: Forbidden: field is immutable when `immutable` is set
```

