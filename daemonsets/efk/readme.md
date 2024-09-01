Certainly, I can help you set up the EFK (Elasticsearch, Fluentd, Kibana) stack on your kind Kubernetes cluster. We'll create the necessary manifests for each component. Let's go through this step-by-step.

1. First, let's create a namespace for our logging stack if we haven't already:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: logging
```

Save this as `logging-namespace.yaml` and apply it:

```
kubectl apply -f logging-namespace.yaml
```

2. Now, let's set up Elasticsearch:



```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: elasticsearch
  namespace: logging
spec:
  serviceName: elasticsearch
  replicas: 1
  selector:
    matchLabels:
      app: elasticsearch
  template:
    metadata:
      labels:
        app: elasticsearch
    spec:
      containers:
      - name: elasticsearch
        image: docker.elastic.co/elasticsearch/elasticsearch:7.10.0
        env:
        - name: discovery.type
          value: single-node
        ports:
        - containerPort: 9200
        - containerPort: 9300
        volumeMounts:
        - name: data
          mountPath: /usr/share/elasticsearch/data
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 10Gi
---
apiVersion: v1
kind: Service
metadata:
  name: elasticsearch
  namespace: logging
spec:
  selector:
    app: elasticsearch
  ports:
  - port: 9200
    targetPort: 9200

```

Save this as `elasticsearch.yaml` and apply it:

```
kubectl apply -f elasticsearch.yaml
```

3. Next, let's set up Fluentd as a DaemonSet:



```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: fluentd
  namespace: logging
  labels:
    app: fluentd
spec:
  selector:
    matchLabels:
      app: fluentd
  template:
    metadata:
      labels:
        app: fluentd
    spec:
      serviceAccount: fluentd
      serviceAccountName: fluentd
      tolerations:
      - key: node-role.kubernetes.io/master
        effect: NoSchedule
      containers:
      - name: fluentd
        image: fluent/fluentd-kubernetes-daemonset:v1-debian-elasticsearch
        env:
          - name:  FLUENT_ELASTICSEARCH_HOST
            value: "elasticsearch.logging.svc.cluster.local"
          - name:  FLUENT_ELASTICSEARCH_PORT
            value: "9200"
          - name: FLUENT_ELASTICSEARCH_SCHEME
            value: "http"
        resources:
          limits:
            memory: 200Mi
          requests:
            cpu: 100m
            memory: 200Mi
        volumeMounts:
        - name: varlog
          mountPath: /var/log
        - name: varlibdockercontainers
          mountPath: /var/lib/docker/containers
          readOnly: true
      terminationGracePeriodSeconds: 30
      volumes:
      - name: varlog
        hostPath:
          path: /var/log
      - name: varlibdockercontainers
        hostPath:
          path: /var/lib/docker/containers
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: fluentd
  namespace: logging
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: fluentd
rules:
- apiGroups:
  - ""
  resources:
  - pods
  - namespaces
  verbs:
  - get
  - list
  - watch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: fluentd
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: fluentd
subjects:
- kind: ServiceAccount
  name: fluentd
  namespace: logging

```

Save this as `fluentd.yaml` and apply it:

```
kubectl apply -f fluentd.yaml
```

4. Finally, let's set up Kibana:



```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: kibana
  namespace: logging
spec:
  replicas: 1
  selector:
    matchLabels:
      app: kibana
  template:
    metadata:
      labels:
        app: kibana
    spec:
      containers:
      - name: kibana
        image: docker.elastic.co/kibana/kibana:7.10.0
        env:
        - name: ELASTICSEARCH_URL
          value: http://elasticsearch:9200
        ports:
        - containerPort: 5601
---
apiVersion: v1
kind: Service
metadata:
  name: kibana
  namespace: logging
spec:
  selector:
    app: kibana
  ports:
  - port: 5601
    targetPort: 5601

```

Save this as `kibana.yaml` and apply it:

```
kubectl apply -f kibana.yaml
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
