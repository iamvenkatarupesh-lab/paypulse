# ============================================================================
# DB SUBNET GROUP
# RDS requires subnets in at least 2 AZs (even for single-AZ instances) so it
# can failover or move the instance if a hardware issue occurs.
# We use all 3 private subnets from the network stack.
# ============================================================================
resource "aws_db_subnet_group" "main" {
  name       = "${var.db_identifier}-subnet-group"
  subnet_ids = data.terraform_remote_state.network.outputs.private_subnet_ids

  tags = {
    Name = "${var.db_identifier}-subnet-group"
  }
}

# ============================================================================
# SECURITY GROUP for RDS
# Allows inbound PostgreSQL (5432/tcp) from anything inside the VPC.
# In production, tighten to specific source security groups (e.g., only EKS).
# ============================================================================
resource "aws_security_group" "rds" {
  name        = "${var.db_identifier}-sg"
  description = "Allow PostgreSQL access from within the VPC"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

  ingress {
    description = "PostgreSQL from anywhere in the VPC"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [data.terraform_remote_state.network.outputs.vpc_cidr_block]
  }

  egress {
    description = "Allow all outbound (default)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.db_identifier}-sg"
  }
}

# ============================================================================
# RANDOM PASSWORD
# Generated at apply time, never committed to git.
# Stored in Secrets Manager for apps to retrieve at runtime.
# ============================================================================
resource "random_password" "db" {
  length           = 32
  special          = true
  override_special = "!#$%&*+-.<=>?_~"
}

# ============================================================================
# SECRETS MANAGER SECRET
# The secret container. Apps read this via IAM permissions (IRSA in EKS).
# recovery_window_in_days=0 means immediate deletion on destroy (dev convenience).
# In production, leave the default (30-day soft delete).
# ============================================================================
resource "aws_secretsmanager_secret" "db" {
  name                    = "${var.project_name}/${var.environment}/db-credentials"
  description             = "PostgreSQL master credentials for ${var.db_identifier}"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id

  secret_string = jsonencode({
    username = var.db_username
    password = random_password.db.result
    host     = aws_db_instance.main.address
    port     = aws_db_instance.main.port
    dbname   = var.db_name
  })
}

# ============================================================================
# RDS POSTGRESQL INSTANCE
# Single-AZ for dev. Multi-AZ doubles cost. Takes ~5-7 minutes to provision.
# ============================================================================
resource "aws_db_instance" "main" {
  identifier     = var.db_identifier
  engine         = "postgres"
  engine_version = var.db_engine_version
  instance_class = var.db_instance_class

  allocated_storage     = var.db_allocated_storage_gb
  max_allocated_storage = var.db_max_allocated_storage_gb
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = var.db_name
  username = var.db_username
  password = random_password.db.result

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false

  backup_retention_period = var.db_backup_retention_days
  backup_window           = "03:00-04:00"
  maintenance_window      = "sun:04:30-sun:05:30"

  skip_final_snapshot      = true
  delete_automated_backups = true
  deletion_protection      = false

  performance_insights_enabled = true
  auto_minor_version_upgrade   = true

  tags = {
    Name = var.db_identifier
  }
}
