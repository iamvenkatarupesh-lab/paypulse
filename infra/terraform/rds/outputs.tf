output "db_instance_endpoint" {
  description = "Connection endpoint (hostname:port) for the database"
  value       = aws_db_instance.main.endpoint
}

output "db_instance_address" {
  description = "Hostname of the database (no port)"
  value       = aws_db_instance.main.address
}

output "db_instance_port" {
  description = "Database port"
  value       = aws_db_instance.main.port
}

output "db_name" {
  description = "Initial database name"
  value       = aws_db_instance.main.db_name
}

output "db_security_group_id" {
  description = "Security group ID protecting the database"
  value       = aws_security_group.rds.id
}

output "db_secret_arn" {
  description = "ARN of the Secrets Manager secret containing credentials"
  value       = aws_secretsmanager_secret.db.arn
}

output "db_secret_name" {
  description = "Name of the Secrets Manager secret (apps reference this)"
  value       = aws_secretsmanager_secret.db.name
}

output "db_fetch_password_command" {
  description = "AWS CLI command to retrieve the password (for manual debugging)"
  value       = "aws secretsmanager get-secret-value --secret-id ${aws_secretsmanager_secret.db.name} --query SecretString --output text | jq -r .password"
}
