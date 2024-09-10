# To use this updated configuration in your kind cluster:

Save the YAML content to a file (e.g., k8s-labels-selectors-annotations.yaml).
Apply the configuration with:

```
kubectl apply -f k8s-labels-selectors-annotations.yaml
```

This will create or update the resources in your kind cluster with both labels and annotations.
To view the annotations on a resource, you can use the -o yaml flag with kubectl. For example:

```
kubectl get deployment web-app -n label-demo -o yaml
```

This will show you the full YAML representation of the deployment, including its annotations.
