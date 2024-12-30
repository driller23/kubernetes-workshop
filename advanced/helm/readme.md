# Deploy WordPress and MariaDB using Helm

This guide demonstrates how to deploy WordPress and MariaDB using Helm charts, including both development and production configurations.

## Prerequisites

- Kubernetes cluster
- [Helm](https://helm.sh/docs/intro/install/) installed
- [kubectl](https://kubernetes.io/docs/tasks/tools/) configured

## Installation

1. Add the Bitnami repository:

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
```

2. Install WordPress:

```bash
helm install my-wordpress bitnami/wordpress --version 24.1.4
```

3. Search Application version in bitnami

```
helm search repo bitnami/wordpress --versions
```

## Getting Admin Credentials

### For Mac/Linux:
```bash
echo Username: user
echo Password: $(kubectl get secret --namespace default my-wordpress -o jsonpath="{.data.wordpress-password}" | base64 --decode)
```

### For Windows PowerShell:
```powershell
$pw=kubectl get secret --namespace default my-wordpress -o jsonpath="{.data.wordpress-password}"
[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($pw))
```

## Access WordPress

- Application URL: http://localhost
- Admin interface: https://localhost/admin

## Production Deployment

For production environments, we can scale WordPress and enable metrics collection.

1. Create a `values-production.yaml` file:

```yaml
# Scale WordPress instances
replicaCount: 3

# Enable metrics collection
metrics:
  enabled: true
  image:
    registry: docker.io
    repository: bitnami/apache-exporter
    tag: 0.8.0-debian-10-r243
```

2. Remove the development deployment:
```bash
helm delete my-wordpress
```

3. Install production configuration:
```bash
helm install my-wordpress-prod bitnami/wordpress --version 10.1.4 -f values-production.yaml
```

4. Verify the deployment:
```bash
kubectl get pods
```

Expected output:
```
NAME                                 READY   STATUS    RESTARTS   AGE
my-wordpress-prod-5c9776c976-4bs6f   2/2     Running   0          103s
my-wordpress-prod-5c9776c976-9ssmr   2/2     Running   0          103s
my-wordpress-prod-5c9776c976-sfq84   2/2     Running   0          103s
my-wordpress-prod-mariadb-0          1/1     Running   0          103s
```

## Accessing Metrics

1. Forward the metrics port:
```bash
kubectl port-forward <pod-name> 9117:9117
```
Replace `<pod-name>` with an actual pod name from `kubectl get pods`

2. Access metrics at: http://localhost:9117

Example metrics:
```
apache_cpuload 1.2766
process_resident_memory_bytes 1.6441344e+07
```

## Cleanup

Remove the deployment:
```bash
helm delete my-wordpress-prod
```

## Additional Configuration

- The WordPress Helm chart supports auto-scaling and additional configurations
- MariaDB can be scaled with multiple replicas
- Check the [WordPress Chart documentation](https://github.com/bitnami/charts/tree/master/bitnami/wordpress) for more options

## Contributing

Feel free to submit issues and enhancement requests!

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
