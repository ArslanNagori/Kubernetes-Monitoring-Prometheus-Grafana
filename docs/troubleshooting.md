# Common issues and fixes

| Symptom | Likely cause | Fix |
| ------- | ------------ | --- |
| `helm install` times out | Pods are still pulling images or lack resources | `kubectl -n monitoring get pods`, then `kubectl -n monitoring describe pod <name>`; raise `--timeout` or free resources |
| Grafana login fails | Wrong password or the secret was recreated | Read it again from the `grafana-admin` secret |
| Prometheus shows no data for a namespace | Wrong namespace name in the query | Check `kubectl get ns` and fix the label value |
| Targets show as down in Prometheus | Network policy or a node that is not Ready | Check the Targets page, then `kubectl get nodes` |
| `port-forward` drops | The pod restarted | Re-run `make port-forward` |
| Grafana pod count does not match `kubectl` | The panel counts containers, not pods | Compare with `kubectl get pods -A` |
| Helm cannot find the chart | Repo not added or stale | `helm repo add prometheus-community https://prometheus-community.github.io/helm-charts` then `helm repo update` |
