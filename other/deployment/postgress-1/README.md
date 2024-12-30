### Run these commands 

```
kubectl apply -f postgres-config.yaml  # Optional
kubectl apply -f my-postgres.yaml
```

To specify multiple replicas in your YAML file, simply modify the replicas section to the number you desire:

```
spec:
  replicas: 10
```
