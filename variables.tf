variable "vpc_id" {
  type        = string
  description = "VPC ID for creating RDS instances"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for creating RDS instances"
}

variable "databases" {
  type = map(object({
    engine                              = string
    engine_version                      = string
    family                              = string
    instance_class                      = string
    allocated_storage                   = number
    max_allocated_storage               = number
    master_username                     = optional(string, "root")
    password_rotation_version           = optional(number, 1)
    manage_master_user_password         = optional(bool, false) # BUG: when enabled, replicas cannot be created
    iam_database_authentication_enabled = optional(bool, false)
    backup_retention_period             = optional(number, 7)
    skip_final_snapshot                 = optional(bool, false)
    deletion_protection                 = optional(bool, true)
    apply_immediately                   = optional(bool, false)

    replicas = optional(map(object({
      engine                  = optional(string)
      engine_version          = optional(string)
      family                  = optional(string)
      instance_class          = optional(string)
      allocated_storage       = optional(number)
      max_allocated_storage   = optional(number)
      backup_retention_period = optional(number, 0)
      skip_final_snapshot     = optional(bool, true)
      deletion_protection     = optional(bool, false)
      apply_immediately       = optional(bool, false)
    })), {})

    security_groups = map(object({
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
  }))
  description = "Map of databases and their security groups to create"
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Additional tags to apply to the created resources"
  default     = {}
}
