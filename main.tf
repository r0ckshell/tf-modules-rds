module "aws_secret_password" {
  for_each = {
    for db_key, db_config in var.databases :
    db_key => db_config
    if !db_config.manage_master_user_password
  }

  source = "./aws_secret_password"

  database_name             = each.key
  password_rotation_version = try(each.value.password_rotation_version, 1)

  tags = merge(local.tags, { Name = "db-${each.key}-master-password" })
}

module "aws_security_groups" {
  for_each = var.databases

  source = "./aws_security_group"

  vpc_id          = var.vpc_id
  security_groups = each.value.security_groups

  tags = merge(local.tags, { Name = "${each.key}-sg" })
}

module "main" {
  for_each = var.databases

  source  = "terraform-aws-modules/rds/aws"
  version = "6.13.1"

  create_db_option_group    = false
  create_db_parameter_group = false
  create_monitoring_role    = false

  identifier = each.key

  engine                = each.value.engine
  engine_version        = each.value.engine_version
  family                = each.value.family
  instance_class        = each.value.instance_class
  allocated_storage     = each.value.allocated_storage
  max_allocated_storage = each.value.max_allocated_storage

  auto_minor_version_upgrade = true

  username                            = each.value.master_username
  password                            = each.value.manage_master_user_password ? null : module.aws_secret_password[each.key].secret_string
  manage_master_user_password         = each.value.manage_master_user_password
  iam_database_authentication_enabled = each.value.iam_database_authentication_enabled

  performance_insights_enabled          = true
  performance_insights_retention_period = 7

  create_db_subnet_group          = true
  db_subnet_group_use_name_prefix = false
  db_subnet_group_name            = "${each.key}-subnets"
  db_subnet_group_description     = "Subnet group for ${each.key}"
  subnet_ids                      = var.subnet_ids

  vpc_security_group_ids = module.aws_security_groups[each.key].ids

  copy_tags_to_snapshot = true

  deletion_protection = each.value.deletion_protection
  apply_immediately   = each.value.apply_immediately

  tags = merge(local.tags, {
    terraform-aws-module = "terraform-aws-modules/rds/aws"
  })
}

module "replica" {
  for_each = local.replicas

  source  = "terraform-aws-modules/rds/aws"
  version = "6.13.1"

  identifier          = each.value.replica_key
  replicate_source_db = module.main[each.value.database_key].db_instance_arn
  multi_az            = false

  engine                = each.value.engine
  engine_version        = each.value.engine_version
  family                = each.value.family
  instance_class        = each.value.instance_class
  allocated_storage     = each.value.allocated_storage
  max_allocated_storage = each.value.max_allocated_storage

  auto_minor_version_upgrade = true

  performance_insights_enabled          = true
  performance_insights_retention_period = 7

  vpc_security_group_ids = module.aws_security_groups[each.value.database_key].ids

  copy_tags_to_snapshot = true

  backup_retention_period = each.value.replica_config.backup_retention_period
  deletion_protection     = each.value.replica_config.deletion_protection
  skip_final_snapshot     = each.value.replica_config.skip_final_snapshot
  apply_immediately       = each.value.replica_config.apply_immediately

  tags = merge(local.tags, {
    terraform-aws-module = "terraform-aws-modules/rds/aws"
    MasterDBName         = "${module.main[each.value.database_key].db_instance_identifier}"
  })
}
