output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  description = "Kubernetes API endpoint URL"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64-encoded CA cert used to talk to the cluster"
  value       = aws_eks_cluster.main.certificate_authority[0].data
  sensitive   = true
}

output "cluster_version" {
  description = "Kubernetes version of the cluster"
  value       = aws_eks_cluster.main.version
}

output "cluster_oidc_issuer_url" {
  description = "OIDC issuer URL for IRSA"
  value       = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

output "oidc_provider_arn" {
  description = "ARN of the IAM OIDC provider (for IRSA trust policies)"
  value       = aws_iam_openid_connect_provider.main.arn
}

output "node_group_arn" {
  description = "ARN of the managed node group"
  value       = aws_eks_node_group.main.arn
}

output "node_role_arn" {
  description = "ARN of the IAM role attached to worker nodes"
  value       = aws_iam_role.node.arn
}

output "kubeconfig_update_command" {
  description = "Command to update local kubeconfig to talk to this cluster"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.main.name}"
}
