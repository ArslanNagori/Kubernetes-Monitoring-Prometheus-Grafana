# Setup guide

## 1. Tools

| Tool | Needed for |
| ---- | ---------- |
| Docker | Kind |
| kind | Local cluster |
| kubectl | Talking to the cluster |
| helm | Installing the monitoring chart |
| AWS CLI and eksctl | Only for the EKS run |
| trivy | Optional: security scan |

## 2. Local run on Kind

```bash
make kind-up
kubectl get nodes              # all nodes should be Ready
make monitoring
kubectl -n monitoring get pods # wait until every pod is Running
make port-forward
```

Open Grafana at http://localhost:3000. The user is `admin`. Read the password:

```bash
kubectl -n monitoring get secret grafana-admin -o jsonpath='{.data.admin-password}' | base64 -d
```

Open Prometheus at http://localhost:9090 and try the queries in [monitoring.md](monitoring.md).

## 3. Run on Amazon EKS

1. Create or reuse an EKS cluster (this repo does not create one; see the [EKS-GitOps-Deployment](https://github.com/ArslanNagori/EKS-GitOps-Deployment) project).
2. Point `kubectl` at it: `aws eks update-kubeconfig --name <cluster-name> --region <region>`.
3. Run `make monitoring`. The same `monitoring/values.yaml` is used.
4. Run `make port-forward` and open Grafana and Prometheus as above.

## 4. Security checks

```bash
APP_DIR=/path/to/workload make scan
```

Reports land in `reports/`.

## 5. Clean up

```bash
make destroy      # removes the Helm release and the namespace
make kind-down    # deletes the local cluster
```
