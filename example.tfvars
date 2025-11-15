vpc_id     = "vpc-123qwertyuiop"
subnet_ids = ["subnet-abc123", "subnet-def456"]

tags = {
  Environment = "development"
  Owner       = "data-team"
}

databases = {
  "postgresql" = {
    engine                      = "postgres"
    engine_version              = "14.17"
    family                      = "postgres14"
    instance_class              = "db.t4g.small"
    allocated_storage           = 16
    max_allocated_storage       = 32
    master_username             = "r00t"
    password_rotation_version   = 1
    manage_master_user_password = false

    replicas = {
      "read-only-replica" = {
        instance_class          = "db.t4g.small"
        allocated_storage       = 16
        max_allocated_storage   = 32
        backup_retention_period = 0     # No backups by default
        skip_final_snapshot     = true  # No final snapshot by default
        deletion_protection     = false # No deletion protection by default
      }
    }

    security_groups = {
      "postgresql-sg" = {
        description = "Security group for the PostgreSQL RDS instance"
        ingress_rules = [{
          description      = "Allow incoming connections to port 5432 from the VPC"
          from_port        = 5432
          to_port          = 5432
          protocol         = "tcp"
          cidr_blocks      = ["10.0.0.0/16"]
          ipv6_cidr_blocks = []
          security_groups  = []
          self             = false
        }]
        egress_rules = [{
          description = "Allow all outbound traffic"
          protocol    = "-1"
        }]
      }
    }
  }
}
