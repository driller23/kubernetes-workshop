Certainly, I can help you set up the EFK (Elasticsearch, Fluentd, Kibana) stack on your kind Kubernetes cluster. We'll create the necessary manifests for each component. Let's go through this step-by-step.

1. First, let's create a namespace for our logging stack if we haven't already:

Save this as `logging-namespace.yaml` and apply it:

```
kubectl apply -f logging-namespace.yaml
```

2. Now, let's set up Elasticsearch:

```
kubectl apply -f elasticsearch-statefulset.yaml
```

3. Next, let's set up Fluentd as a DaemonSet:

```
kubectl apply -f fluentd-daemonset.yaml
```

4. Finally, let's set up Kibana:

```
kubectl apply -f kibana-deployment.yaml
```

Now you have the EFK (Elasticsearch, Fluentd, Kibana) stack installed on your kind Kubernetes cluster with Fluentd running as a DaemonSet. To access these services:

1. For Elasticsearch:
   ```
   kubectl port-forward -n logging svc/elasticsearch 9200:9200
   ```
   Then access it at http://localhost:9200

2. For Kibana:
   ```
   kubectl port-forward -n logging svc/kibana 5601:5601
   ```
   Then access it at http://localhost:5601

Remember that this is a basic setup and might need further configuration depending on your specific requirements. For example, you might want to add persistent storage for Elasticsearch in a production environment.

Also, note that Fluentd is configured to collect logs from all pods in the cluster and send them to Elasticsearch. You may need to adjust the Fluentd configuration if you have specific logging requirements.

Would you like me to explain any part of this setup in more detail or help with any specific configuration?
