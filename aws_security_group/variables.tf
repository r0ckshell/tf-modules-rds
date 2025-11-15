variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "security_groups" {
  type = map(object({
    description = string
    ingress_rules = optional(list(object({
      description      = string
      port             = optional(number)
      from_port        = optional(number)
      to_port          = optional(number)
      protocol         = optional(string, "-1")
      cidr_blocks      = optional(list(string), [])
      ipv6_cidr_blocks = optional(list(string), [])
      prefix_list_ids  = optional(list(string), [])
      security_groups  = optional(list(string), [])
      self             = optional(bool, false)
    })), [])
    egress_rules = optional(list(object({
      description      = string
      port             = optional(number)
      from_port        = optional(number)
      to_port          = optional(number)
      protocol         = optional(string, "-1")
      cidr_blocks      = optional(list(string), [])
      ipv6_cidr_blocks = optional(list(string), [])
      prefix_list_ids  = optional(list(string), [])
      security_groups  = optional(list(string), [])
      self             = optional(bool, false)
    })), [])
  }))
  description = "Security group map with ingress and egress rules"
}

variable "tags" {
  type        = map(string)
  description = "Additional tags to apply to the security groups"
  default     = {}
}
