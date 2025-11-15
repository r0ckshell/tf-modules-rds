locals {
  module_tags = {
    terraform-module = "rds/aws_secret_password"
    CreatedBy        = "Terraform"
  }
  tags = merge(var.tags, local.module_tags)
}
