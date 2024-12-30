# Initial Deployment:

## Apply the deployment
```kubectl apply -f deployment.yaml```

## Check rollout status
```kubectl rollout status deployment/nginx-deployment```

## View rollout history
```kubectl rollout history deployment/nginx-deployment```

# Performing a Rollout (Update):

## Update to new version
```kubectl set image deployment/nginx-deployment nginx=nginx:1.16.1 --record```

## Alternative: edit deployment and change image
```kubectl edit deployment/nginx-deployment```

## Monitor the rollout
```kubectl rollout status deployment/nginx-deployment```

## View deployment details
```kubectl describe deployment nginx-deployment```

# Rollback Commands

# Rollback to previous version
```kubectl rollout undo deployment/nginx-deployment```

## Rollback to specific revision
```kubectl rollout undo deployment/nginx-deployment --to-revision=2```

## Pause rollout
```kubectl rollout pause deployment/nginx-deployment```

## Resume rollout
```kubectl rollout resume deployment/nginx-deployment```
