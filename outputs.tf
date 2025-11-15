output "main_identifier" {
  value = values(module.main)[*].db_instance_identifier
}

output "main_endpoint" {
  value = values(module.main)[*].db_instance_endpoint
}
