.PHONY: kind-up kind-down monitoring port-forward scan destroy lint help

NAMESPACE ?= monitoring
RELEASE   ?= monitoring
# Pin a chart version for repeatable installs, for example: make monitoring CHART_VERSION=<x.y.z>
CHART_VERSION ?=

help:
	@echo "kind-up        create the local Kind cluster"
	@echo "kind-down      delete the local Kind cluster"
	@echo "monitoring     install Prometheus, Alertmanager and Grafana"
	@echo "port-forward   Grafana on :3000 and Prometheus on :9090"
	@echo "scan           run Trivy and OWASP Dependency-Check"
	@echo "destroy        remove the monitoring release and namespace"
	@echo "lint           run ShellCheck and yamllint"

kind-up:
	kind create cluster --name monitoring --config kind/kind-config.yaml

kind-down:
	kind delete cluster --name monitoring

monitoring:
	NAMESPACE=$(NAMESPACE) RELEASE=$(RELEASE) CHART_VERSION=$(CHART_VERSION) ./scripts/install-monitoring.sh

port-forward:
	@echo "Grafana: http://localhost:3000   Prometheus: http://localhost:9090   (Ctrl+C to stop)"
	@kubectl -n $(NAMESPACE) port-forward svc/$(RELEASE)-grafana 3000:80 & \
	 kubectl -n $(NAMESPACE) port-forward svc/$(RELEASE)-kube-prometheus-prometheus 9090:9090

scan:
	./scripts/security-scan.sh

destroy:
	NAMESPACE=$(NAMESPACE) RELEASE=$(RELEASE) ./scripts/cleanup.sh

lint:
	shellcheck scripts/*.sh
	yamllint .
