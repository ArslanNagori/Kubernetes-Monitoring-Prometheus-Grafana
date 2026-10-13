#!/usr/bin/env bash
# Remove the monitoring release and its namespace.
set -euo pipefail

NAMESPACE="${NAMESPACE:-monitoring}"
RELEASE="${RELEASE:-monitoring}"

helm uninstall "$RELEASE" --namespace "$NAMESPACE" || true
kubectl delete namespace "$NAMESPACE" --ignore-not-found
echo "Removed release $RELEASE and namespace $NAMESPACE."
echo "On EKS, also delete the cluster if you no longer need it (see docs/cost-and-cleanup.md)."
