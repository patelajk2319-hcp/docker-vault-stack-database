terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 5.0"
    }
  }
}

# Mount the database secrets engine if not already mounted
resource "vault_mount" "database" {
  path        = "database/redis"
  type        = "database"
  description = "Database secrets engine for Redis credential mangement"
}

# Configure the Redis database connection using a custom plugin
# Note that the username and password below must exist before this will successfully
resource "vault_database_secret_backend_connection" "redis" {
  backend       = vault_mount.database.path
  name          = "my-redis-database"
  plugin_name   = "redis-database-plugin"
  allowed_roles = ["redis-dynamic-role", "redis-dynamic-readonly-role", "redis-dynamic-admin-role"]
  // rotation_period = 120 // Rotate the credential after this period in seconds

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
resource "vault_database_secret_backend_role" "redis_dynamic_role" {
  backend = vault_mount.database.path
  name    = "redis-dynamic-role"
  db_name = vault_database_secret_backend_connection.redis.name

  creation_statements = [
    "[\"~*\", \"+@read\", \"+@write\", \"-@dangerous\"]"
  ]

  default_ttl = 3600  # 1 hour
  max_ttl     = 86400 # 24 hours
}

# Define the Redis role
resource "vault_database_secret_backend_role" "redis_dynamic_readonly_role" {
  backend = vault_mount.database.path
  name    = "redis-dynamic-readonly-role"
  db_name = vault_database_secret_backend_connection.redis.name

  # Read-only ACL permissions for dynamic users
  creation_statements = [
    "[\"~*\", \"+@read\", \"+info\", \"+ping\"]"
  ]

  default_ttl = 7200  # 2 hours
  max_ttl     = 86400 # 24 hours
}

# Create Redis role
resource "vault_database_secret_backend_role" "redis_dynamic_admin_role" {
  backend = vault_mount.database.path
  name    = "redis-dynamic-admin-role"
  db_name = vault_database_secret_backend_connection.redis.name

  # Admin ACL permissions for dynamic users (full access)
  creation_statements = [
    "[\"~*\", \"+@all\"]"
  ]

  default_ttl = 1800 # 30 minutes
  max_ttl     = 7200 # 2 hours
}
