#!/usr/bin/env bash
# Run Trivy (misconfiguration scan) and OWASP Dependency-Check before deploying.
# Reports are written to reports/. The script reports findings without failing the run.
set -uo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPORT_DIR="$ROOT_DIR/reports"
APP_DIR="${APP_DIR:-}"   # path to the workload source, for example the Wanderlust app
mkdir -p "$REPORT_DIR"

if command -v trivy >/dev/null 2>&1; then
  echo "Trivy: scanning manifests and Helm values"
  trivy config "$ROOT_DIR" --severity HIGH,CRITICAL \
    --format table --output "$REPORT_DIR/trivy-config-report.txt" || true
  echo "Trivy report: reports/trivy-config-report.txt"
else
  echo "trivy not found, skipping" >&2
fi

if [ -n "$APP_DIR" ] && command -v dependency-check.sh >/dev/null 2>&1; then
  echo "OWASP Dependency-Check: scanning $APP_DIR"
  dependency-check.sh --project "monitored-workload" --scan "$APP_DIR" \
    --format "HTML" --out "$REPORT_DIR" || true
  echo "OWASP report: reports/dependency-check-report.html"
else
  echo "Set APP_DIR and install dependency-check.sh to run the OWASP scan" >&2
fi
