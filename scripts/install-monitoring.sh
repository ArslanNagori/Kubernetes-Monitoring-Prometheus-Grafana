#!/usr/bin/env bash
# Install Prometheus, Alertmanager and Grafana with the kube-prometheus-stack chart.
set -euo pipefail

NAMESPACE="${NAMESPACE:-monitoring}"
RELEASE="${RELEASE:-monitoring}"
CHART_VERSION="${CHART_VERSION:-}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

for cmd in kubectl helm; do
  command -v "$cmd" >/dev/null 2>&1 || { echo "Missing required tool: $cmd" >&2; exit 1; }
done

echo "Cluster: $(kubectl config current-context)"

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts >/dev/null 2>&1 || true
helm repo update >/dev/null

kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

# Create the Grafana admin secret once. The password is generated, never committed.
if ! kubectl -n "$NAMESPACE" get secret grafana-admin >/dev/null 2>&1; then
  GRAFANA_PASSWORD="${GRAFANA_PASSWORD:-$(head -c 24 /dev/urandom | base64 | tr -d '/+=' | head -c 20)}"
  kubectl -n "$NAMESPACE" create secret generic grafana-admin \
    --from-literal=admin-user=admin \
    --from-literal=admin-password="$GRAFANA_PASSWORD"
  echo "Created secret grafana-admin. Read the password with:"
  echo "  kubectl -n $NAMESPACE get secret grafana-admin -o jsonpath='{.data.admin-password}' | base64 -d"
fi

VERSION_ARGS=()
if [ -n "$CHART_VERSION" ]; then
  VERSION_ARGS=(--version "$CHART_VERSION")
fi

helm upgrade --install "$RELEASE" prometheus-community/kube-prometheus-stack \
  --namespace "$NAMESPACE" \
  --values "$ROOT_DIR/monitoring/values.yaml" \
  "${VERSION_ARGS[@]}" \
  --wait --timeout 10m

echo "Done. Pods in $NAMESPACE:"
kubectl -n "$NAMESPACE" get pods
