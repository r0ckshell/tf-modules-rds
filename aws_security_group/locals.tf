locals {
  module_tags = {
    terraform-module = "rds/aws_security_group"
    CreatedBy        = "Terraform"
  }
  tags = merge(var.tags, local.module_tags)
}
