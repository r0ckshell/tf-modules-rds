locals {
  module_tags = {
    terraform-module = "rds"
    CreatedBy        = "Terraform"
  }
  tags = merge(var.tags, local.module_tags)

  # Flatten databases and replicas into a single map for iteration
  replicas = merge(
    {},
    merge([
      for db_key, db_config in var.databases : {
        for replica_key, replica_config in db_config.replicas : "${db_key}-${replica_key}" => {
          database_key    = db_key
          replica_key     = replica_key
          database_config = db_config
          replica_config  = replica_config
          # Use the master database configuration values for the replica if not provided
          engine                = coalesce(replica_config.engine, db_config.engine)
          engine_version        = coalesce(replica_config.engine_version, db_config.engine_version)
          family                = coalesce(replica_config.family, db_config.family)
          instance_class        = coalesce(replica_config.instance_class, db_config.instance_class)
          allocated_storage     = coalesce(replica_config.allocated_storage, db_config.allocated_storage)
          max_allocated_storage = coalesce(replica_config.max_allocated_storage, db_config.max_allocated_storage)
        }
      }
    ]...)
  )
}
