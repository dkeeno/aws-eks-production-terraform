#!/usr/bin/env bash
# Render K8s manifests with real values from Terraform outputs and apply.
set -euo pipefail

TAG="${1:-dev}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
K8S="$ROOT/app/k8s"

cd "$ROOT/terraform"
ECR_URL="$(terraform output -raw ecr_repository_url)"
APP_ROLE_ARN="$(terraform output -raw app_iam_role_arn)"

# 1) Install Secrets Store CSI Driver + AWS provider (idempotent)
echo "Ensuring Secrets Store CSI Driver is installed…"
helm repo add secrets-store-csi-driver https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts >/dev/null
helm repo update >/dev/null
helm upgrade --install csi-secrets-store secrets-store-csi-driver/secrets-store-csi-driver \
  -n kube-system --set syncSecret.enabled=true --set enableSecretRotation=true >/dev/null

kubectl apply -f \
  https://raw.githubusercontent.com/aws/secrets-store-csi-driver-provider-aws/main/deployment/aws-provider-installer.yaml >/dev/null

# 2) Render manifests
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
cp "$K8S"/*.yaml "$TMP/"
sed -i.bak "s|<ECR_URL>|${ECR_URL}|g" "$TMP/deployment.yaml"
sed -i.bak "s|v0.1.0|${TAG}|g" "$TMP/deployment.yaml"
sed -i.bak "s|arn:aws:iam::<ACCOUNT_ID>:role/demo-eks-dev-hello-world|${APP_ROLE_ARN}|g" "$TMP/serviceaccount.yaml"
rm -f "$TMP"/*.bak

# 3) Apply
kubectl apply -f "$TMP/namespace.yaml"
kubectl apply -f "$TMP/serviceaccount.yaml"
kubectl apply -f "$TMP/secretproviderclass.yaml"
kubectl apply -f "$TMP/service.yaml"
kubectl apply -f "$TMP/deployment.yaml"
kubectl apply -f "$TMP/ingress.yaml"

echo "Deployed. Watch rollout:"
echo "  kubectl rollout status deploy/hello-world -n hello-world"
