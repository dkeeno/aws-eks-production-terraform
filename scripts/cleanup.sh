#!/usr/bin/env bash
# Remove the app and its namespace. Keeps cluster + infra intact.
set -euo pipefail

kubectl delete namespace hello-world --ignore-not-found

echo "App removed. To destroy infra: cd terraform && terraform destroy"
