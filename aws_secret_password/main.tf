resource "random_password" "this" {
  length           = 32
  special          = true
  min_special      = 6
  override_special = "!#$%^&*()-_=+[]{}<>:?"
  keepers = {
    pass_version = var.password_rotation_version
  }
}

resource "aws_secretsmanager_secret" "this" {
  name                    = "db-${var.database_name}-master-password"
  description             = "The master password for the ${var.database_name} database."
  recovery_window_in_days = 0

  tags = local.tags
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id = aws_secretsmanager_secret.this.id
  secret_string = jsonencode({
    password = "${random_password.this.result}"
  })
}
