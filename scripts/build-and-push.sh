#!/usr/bin/env bash
# Build the app image and push to ECR.
# Usage: ./build-and-push.sh <tag>
set -euo pipefail

TAG="${1:-dev}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$ROOT/terraform"
ECR_URL="$(terraform output -raw ecr_repository_url)"
REGION="$(terraform output -raw kubeconfig_command | awk '{for (i=1;i<=NF;i++) if ($i=="--region") print $(i+1)}')"

echo "Logging into ECR ($ECR_URL)…"
aws ecr get-login-password --region "$REGION" \
  | docker login --username AWS --password-stdin "$(echo "$ECR_URL" | cut -d/ -f1)"

echo "Building $ECR_URL:$TAG…"
cd "$ROOT/app"
docker build --platform linux/amd64 -t "$ECR_URL:$TAG" .

echo "Pushing $ECR_URL:$TAG…"
docker push "$ECR_URL:$TAG"

echo "Done. Image: $ECR_URL:$TAG"
