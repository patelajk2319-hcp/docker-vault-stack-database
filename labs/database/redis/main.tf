terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 5.0"
    }
  }
}

locals {
  admin-role-name = "${var.application-name}-dynamic-admin-role"
  readonly-role-name = "${var.application-name}-dynamic-readonly-role"
}


# Mount the database secrets engine if not already mounted
resource "vault_mount" "database" {
  path        = "database/redis/${var.application-name}"
  type        = "database"
  description = "Database secrets engine for Redis credential mangement"
}

# Configure the Redis database connection using a custom plugin
# Note that the username and password below must exist before this will successfully
resource "vault_database_secret_backend_connection" "redis" {
  backend       = vault_mount.database.path
  name          = "${var.database-name}"
  plugin_name   = "redis-database-plugin"
  allowed_roles = ["${local.admin-role-name}", "${local.readonly-role-name}"]
  //rotation_period = 120 // Rotate the credential after this period in seconds - for dev & testing leave this out

  redis {
    host     = "redis"
    port     = 6379
    username = "vault-dynamic-user"
    password = "SuperSecretPass123"
    tls      = false
  }

  depends_on = [vault_mount.database]

}

# Define the Redis role
resource "vault_database_secret_backend_role" "redis_readonly_role" {
  backend = vault_mount.database.path
  name    = "${local.readonly-role-name}"
  db_name = vault_database_secret_backend_connection.redis.name

  # Read-only ACL permissions for dynamic users
  creation_statements = [
    "[\"~*\", \"+@read\", \"+info\"]"
  ]

  default_ttl = 7200  # 2 hours
  max_ttl     = 86400 # 24 hours
}

# Create Redis role
resource "vault_database_secret_backend_role" "redis_admin_role" {
  backend = vault_mount.database.path
  name    = "${local.admin-role-name}"
  db_name = vault_database_secret_backend_connection.redis.name

  # Admin ACL permissions for dynamic users (full access)
  creation_statements = [
    "[\"~*\", \"+@all\"]"
  ]

  default_ttl = 1800 # 30 minutes
  max_ttl     = 7200 # 2 hours
}
