variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name used for tagging"
  type        = string
  default     = "paypulse"
}

variable "cluster_name" {
  description = "Name of the EKS cluster (MUST match the eks_cluster_name in network/ stack)"
  type        = string
  default     = "paypulse-eks"
}

variable "kubernetes_version" {
  description = "Kubernetes minor version for the EKS control plane"
  type        = string
  default     = "1.30"
}

variable "node_instance_types" {
  description = "EC2 instance types for the managed node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Minimum number of worker nodes (autoscaling floor)"
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum number of worker nodes (autoscaling ceiling)"
  type        = number
  default     = 4
}

variable "node_disk_size_gb" {
  description = "Root EBS volume size in GB per worker node"
  type        = number
  default     = 20
}
