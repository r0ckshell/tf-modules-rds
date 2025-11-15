resource "aws_security_group" "this" {
  for_each = var.security_groups

  vpc_id      = var.vpc_id
  name_prefix = "${each.key}-"
  description = lookup(each.value, "description", "Managed by Terraform") # Change forces a new resource creation

  dynamic "ingress" {
    for_each = lookup(each.value, "ingress_rules", [])
    content {
      description      = lookup(ingress.value, "description")
      from_port        = try(ingress.value.from_port, ingress.value.port, 0)
      to_port          = try(ingress.value.to_port, ingress.value.port, 0)
      protocol         = lookup(ingress.value, "protocol", "-1")
      cidr_blocks      = lookup(ingress.value, "cidr_blocks", [])
      ipv6_cidr_blocks = lookup(ingress.value, "ipv6_cidr_blocks", [])
      prefix_list_ids  = lookup(ingress.value, "prefix_list_ids", [])
      security_groups  = lookup(ingress.value, "security_groups", [])
      self             = lookup(ingress.value, "self", false)
    }
  }

  dynamic "egress" {
    for_each = lookup(each.value, "egress_rules", [])
    content {
      description      = lookup(egress.value, "description")
      from_port        = try(egress.value.from_port, egress.value.port, 0)
      to_port          = try(egress.value.to_port, egress.value.port, 0)
      protocol         = lookup(egress.value, "protocol", "-1")
      cidr_blocks      = lookup(egress.value, "cidr_blocks", [])
      ipv6_cidr_blocks = lookup(egress.value, "ipv6_cidr_blocks", [])
      prefix_list_ids  = lookup(egress.value, "prefix_list_ids", [])
      security_groups  = lookup(egress.value, "security_groups", [])
      self             = lookup(egress.value, "self", false)
    }
  }

  tags = local.tags

  lifecycle {
    create_before_destroy = true
  }
}
