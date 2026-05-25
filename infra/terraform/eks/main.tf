# ============================================================================
# EKS CLUSTER (control plane)
# Takes ~10-12 minutes to create. The slowest single resource in this project.
# AWS spins up the API server, etcd, and scheduler across multiple AZs.
# ============================================================================
resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = aws_iam_role.cluster.arn
  version  = var.kubernetes_version

  vpc_config {
    # Control plane needs subnets across multiple AZs for HA.
    # Use ALL subnets (public + private) so AWS can choose where ENIs land.
    subnet_ids = concat(
      data.terraform_remote_state.network.outputs.public_subnet_ids,
      data.terraform_remote_state.network.outputs.private_subnet_ids,
    )

    # Public endpoint = you can hit the API server from anywhere on the internet.
    # Private endpoint = you can hit it from inside the VPC.
    # For dev convenience we leave public ON; production typically goes private-only
    # with VPN/bastion access.
    endpoint_public_access  = true
    endpoint_private_access = true
  }

  # CloudWatch log types to enable
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  # Ensure IAM role + policy attachments exist BEFORE creating the cluster
  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSVPCResourceController,
  ]
}

# ============================================================================
# OIDC PROVIDER for IRSA (IAM Roles for Service Accounts)
# Lets Kubernetes ServiceAccounts assume IAM roles via OIDC token exchange.
# Required for things like the AWS Load Balancer Controller, External DNS,
# Cluster Autoscaler, and most modern K8s-AWS integrations.
# ============================================================================
data "tls_certificate" "oidc" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "main" {
  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.oidc.certificates[0].sha1_fingerprint]
}

# ============================================================================
# MANAGED NODE GROUP
# EC2 instances managed by EKS. AWS handles the lifecycle (ASG, AMI, joining
# the cluster). You just declare desired size, instance type, etc.
# ============================================================================
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.cluster_name}-nodes"
  node_role_arn   = aws_iam_role.node.arn

  # Workers go in PRIVATE subnets only. They reach the internet via the NAT
  # Gateway. They reach the control plane via VPC routing.
  subnet_ids = data.terraform_remote_state.network.outputs.private_subnet_ids

  instance_types = var.node_instance_types
  capacity_type  = "ON_DEMAND" # vs SPOT for cheaper but interruptible
  disk_size      = var.node_disk_size_gb

  scaling_config {
    desired_size = var.node_desired_size
    min_size     = var.node_min_size
    max_size     = var.node_max_size
  }

  # Rolling update strategy when changing node config
  update_config {
    max_unavailable = 1
  }

  # Don't recreate the node group just because the AMI version changed.
  # EKS will auto-update node AMIs on its own schedule.
  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  # Ensure node IAM policies are attached BEFORE creating the node group
  depends_on = [
    aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.node_AmazonSSMManagedInstanceCore,
  ]

  tags = {
    Name = "${var.cluster_name}-node"
  }
}
