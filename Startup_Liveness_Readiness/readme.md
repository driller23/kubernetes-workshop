# Troubleshooting

## Check probe logs:

```
kubectl describe pod <pod-name>
```

Look for events related to probe failures.

## Verify probe endpoints:

```
kubectl exec <pod-name> -- curl http://localhost:8080/healthz
```

This can help determine if the probe endpoint is responding correctly.

## Adjust timing parameters:
If probes are failing due to slow responses, consider increasing timeoutSeconds or periodSeconds.

## Use debug mode:
Set failureThreshold to a high value during development to prevent frequent restarts while debugging.
