# Monitoring guide

## Dashboards

The chart installs a set of default Kubernetes dashboards. The ones used in this project:

| What to look at | Where |
| --------------- | ----- |
| Cluster CPU and memory, node count, pod count | Kubernetes / Compute Resources / Cluster |
| CPU and memory by namespace | Kubernetes / Compute Resources / Namespace (Pods) |
| Pod health and restarts | Kubernetes / Compute Resources / Pod |
| Node-level usage | Node Exporter / Nodes |

## Useful PromQL queries

Run these in the Prometheus UI (Graph tab).

CPU used by a namespace, in cores:

```promql
sum(rate(container_cpu_usage_seconds_total{namespace="wanderlust", container!=""}[5m]))
```

Memory used by each pod in a namespace:

```promql
sum by (pod) (container_memory_working_set_bytes{namespace="wanderlust", container!=""})
```

Network received per pod:

```promql
sum by (pod) (rate(container_network_receive_bytes_total{namespace="wanderlust"}[5m]))
```

Network transmitted per pod:

```promql
sum by (pod) (rate(container_network_transmit_bytes_total{namespace="wanderlust"}[5m]))
```

Pods that are not running:

```promql
sum by (namespace, phase) (kube_pod_status_phase{phase!="Running", phase!="Succeeded"} == 1)
```

Deployments with fewer ready replicas than desired:

```promql
kube_deployment_spec_replicas - kube_deployment_status_replicas_available > 0
```

## Reading the numbers

- Pod counts can differ between panels. A pie chart that counts containers will show a higher number than a tile that counts pods. Check against `kubectl get pods -A`.
- CPU is shown in cores. Divide by the number of cores in the cluster to get a percentage.
