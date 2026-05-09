# AWS Secrets Manager secret + IAM role for the sample app to read it via IRSA.
# In the cluster, the Secrets Store CSI Driver mounts this as a file and/or
# syncs it to a K8s secret (see app/k8s/secretproviderclass.yaml).

resource "aws_kms_key" "secrets" {
  description             = "KMS key for Secrets Manager"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  tags                    = local.common_tags
}

resource "aws_kms_alias" "secrets" {
  name          = "alias/${local.cluster_name}-secrets"
  target_key_id = aws_kms_key.secrets.key_id
}

resource "aws_secretsmanager_secret" "app" {
  name       = "${local.cluster_name}/${var.app_name}/api-credentials"
  kms_key_id = aws_kms_key.secrets.id
  tags       = local.common_tags
}

resource "aws_secretsmanager_secret_version" "app" {
  secret_id     = aws_secretsmanager_secret.app.id
  secret_string = jsonencode({
    API_KEY = "<set-via-secrets-manager-rotation-or-manual-rotation>"
  })
}

# IRSA role for the app pod
data "aws_iam_policy_document" "app_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.oidc.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.oidc.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:${var.app_name}:${var.app_name}"]
    }
  }
}

data "aws_iam_policy_document" "app_secrets_read" {
  statement {
    actions   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
    resources = [aws_secretsmanager_secret.app.arn]
  }
  statement {
    actions   = ["kms:Decrypt"]
    resources = [aws_kms_key.secrets.arn]
  }
}

resource "aws_iam_role" "app" {
  name               = "${local.cluster_name}-${var.app_name}"
  assume_role_policy = data.aws_iam_policy_document.app_assume.json
  tags               = local.common_tags
}

resource "aws_iam_role_policy" "app_secrets_read" {
  role   = aws_iam_role.app.name
  name   = "secrets-read"
  policy = data.aws_iam_policy_document.app_secrets_read.json
}
