#!/bin/bash

NAMESPACE="development"
COUNTER=1

while true; do
    POD_NAME="dev-pod-$COUNTER"
    
    kubectl run $POD_NAME --image=busybox -n $NAMESPACE \
    --overrides='
    {
      "spec": {
        "containers": [
          {
            "name": "busybox",
            "image": "busybox",
            "command": ["sleep", "3600"],
            "resources": {
              "requests": {
                "cpu": "200m",
                "memory": "256Mi"
              },
              "limits": {
                "cpu": "400m",
                "memory": "512Mi"
              }
            }
          }
        ]
      }
    }
    ' -- sleep 3600

    if [ $? -ne 0 ]; then
        echo "Failed to create pod $POD_NAME. Quota limit likely reached."
        break
    fi

    echo "Created pod $POD_NAME"
    COUNTER=$((COUNTER+1))
    
    sleep 1  # Wait for 1 second before next iteration
done

echo "Total pods created: $((COUNTER-1))"
kubectl get pods -n $NAMESPACE
kubectl describe quota -n $NAMESPACE
