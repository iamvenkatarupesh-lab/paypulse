variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name for tagging"
  type        = string
  default     = "paypulse"
}

variable "db_identifier" {
  description = "RDS instance identifier (must be unique per region/account)"
  type        = string
  default     = "paypulse-dev"
}

variable "db_name" {
  description = "Initial database name created inside the instance"
  type        = string
  default     = "paypulse"
}

variable "db_username" {
  description = "Master username for the database"
  type        = string
  default     = "paypulse_admin"
}

variable "db_engine_version" {
  description = "PostgreSQL major.minor version"
  type        = string
  default     = "16.4"
}

variable "db_instance_class" {
  description = "EC2-like instance class for RDS"
  type        = string
  default     = "db.t4g.micro"
}

variable "db_allocated_storage_gb" {
  description = "Initial storage in GB (autoscales up to max)"
  type        = number
  default     = 20
}

variable "db_max_allocated_storage_gb" {
  description = "Storage autoscaling cap in GB"
  type        = number
  default     = 100
}

variable "db_backup_retention_days" {
  description = "Days to retain automated backups (0 disables)"
  type        = number
  default     = 7
}
