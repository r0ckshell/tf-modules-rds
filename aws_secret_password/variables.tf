variable "database_name" {
  type        = string
  description = "Database name"
}

variable "password_rotation_version" {
  type        = number
  description = "Increment to force password rotation via random_password keepers"
  default     = 1
}

variable "tags" {
  type        = map(string)
  description = "Additional tags to apply to the secret"
  default     = {}
}
