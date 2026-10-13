# Cost and cleanup

| Environment | Cost | What to remove |
| ----------- | ---- | -------------- |
| Kind | Free | `make kind-down` |
| Amazon EKS | The control plane, worker nodes, volumes and public IPs are billed by the hour | `make destroy` for the monitoring release, then delete the cluster and node group if you no longer need them |

Habits that keep the bill small:

- Test on Kind first and move to EKS only when the setup works.
- Stop or delete EKS resources as soon as the screenshots and checks are done.
- Check the AWS billing page the next day to confirm nothing is still running.
