output "cluster_name" {
  description = "EKS cluster name."
  value       = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  description = "EKS API endpoint."
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_oidc_issuer_url" {
  description = "OIDC issuer URL — used to wire up IRSA for additional workloads."
  value       = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

output "vpc_id" {
  value = aws_vpc.this.id
}

output "ecr_repository_url" {
  description = "ECR repo URL — push your app image here."
  value       = aws_ecr_repository.app.repository_url
}

output "app_iam_role_arn" {
  description = "IAM role ARN that the app pod assumes via IRSA."
  value       = aws_iam_role.app.arn
}

output "app_secret_arn" {
  description = "ARN of the AWS Secrets Manager secret consumed by the app."
  value       = aws_secretsmanager_secret.app.arn
}

output "kubeconfig_command" {
  description = "Run this to configure kubectl."
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${aws_eks_cluster.this.name}"
}
