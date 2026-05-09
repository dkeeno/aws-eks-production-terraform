#!/usr/bin/env bash
# Wait up to 3 min for the ALB to be provisioned, then print its hostname.
set -euo pipefail

ATTEMPTS=18  # 18 × 10s = 3 min
for i in $(seq 1 $ATTEMPTS); do
  HOST="$(kubectl get ingress hello-world -n hello-world -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || true)"
  if [[ -n "${HOST:-}" ]]; then
    echo "http://$HOST"
    exit 0
  fi
  echo "Waiting for ALB… ($i/$ATTEMPTS)"
  sleep 10
done

echo "Timed out waiting for ALB. Try:"
echo "  kubectl describe ingress hello-world -n hello-world"
exit 1
