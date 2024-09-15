# 1. To use these examples in a Kind cluster:

Save each YAML content into separate files (e.g., simple-job.yaml, simple-cronjob.yaml, database-backup-job.yaml).
Create a Kind cluster if you haven't already:

```
kind create cluster
```

## Apply the YAML files:

### first apply the MySQL yaml 

```kubectl apply -f mysql.yaml```

```
kubectl apply -f simple-job.yaml
kubectl apply -f simple-cronjob.yaml
kubectl apply -f database-backup-job.yaml
```

## Monitor the Jobs and CronJobs:
```
kubectl get jobs
kubectl get cronjobs
kubectl get pods
```

# 2. To use this in your Kind cluster:

Save the YAML content into a file (e.g., db-backup-script-configmap.yaml).
Apply the YAML file:

### deploy the MySQL 
```kubectl apply -f db-backup-script-configmap.yaml```

### deploy the backup job
```kubectl apply -f db-backup-script-configmap.yaml```

## Monitor the Job and Pods:
```
kubectl get configmaps
kubectl get jobs
kubectl get pods
```

### This approach offers several advantages:

Separation of Concerns: The backup logic is separate from the Job specification, making it easier to manage and update.
Reusability: The same script can be used by different Jobs or even other types of workloads.
Versioning: You can version control your scripts along with your Kubernetes manifests.
Flexibility: It's easy to modify the script without changing the Job specification or rebuilding container images.
