# Architecture

The stack is the Helm `kube-prometheus-stack` chart. It runs the same way on Kind and on Amazon EKS.

## Data flow

1. **kubelet / cAdvisor** exposes CPU, memory and network usage for every container.
2. **kube-state-metrics** turns Kubernetes objects (pods, deployments, nodes) into metrics, for example pod phase and deployment replicas.
3. **node-exporter** runs on every node and exposes host CPU, memory, disk and network metrics.
4. **Prometheus** scrapes all three on an interval, stores the series and answers PromQL queries.
5. **Grafana** uses Prometheus as its data source and draws the dashboards.
6. **Alertmanager** receives alerts from Prometheus. Alert rules and routes are on the roadmap.

## Where things run

| Component | Namespace | Notes |
| --------- | --------- | ----- |
| Prometheus, Alertmanager, Grafana | `monitoring` | One Helm release named `monitoring` |
| kube-state-metrics | `monitoring` | One pod |
| node-exporter | `monitoring` | One pod per node (DaemonSet) |
| Sample workload | its own namespace | The Wanderlust app in the screenshots runs in the `wanderlust` namespace |

## Why a local cluster first

Kind rebuilds in about a minute and costs nothing, so dashboards, queries and Helm values can be changed and tested freely. Once the setup behaved as expected, the same values file was applied to EKS.

## Access

Both Grafana and Prometheus are reached with `kubectl port-forward`. Nothing is exposed to the public internet.
