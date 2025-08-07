terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 5.0"
    }
  }
}

# Optional: Mount the database secrets engine if not already mounted
resource "vault_mount" "database" {
  path = "database"
  type = "database"
}

# Configure the Redis database connection using a custom plugin
# Note that the username and password below must exist before this will successfully
resource "vault_database_secret_backend_connection" "redis" {
  backend       = vault_mount.database.path
  name          = "my-redis-database"
  plugin_name   = "redis-database-plugin"
  allowed_roles = ["my-*-role"]
  rotation_period = 10 // Rotate the credential after this period in seconds

  redis {
    host     = "redis"
    port     = 6379
    username = "vault-admin-user"
    password = "SuperSecretPass123"
    tls      = false
  }

  depends_on = [vault_mount.database]

}

resource "vault_database_secret_backend_static_role" "period_role" {
  backend             = vault_mount.database.path
  name                = "my-static-role"
  db_name             = vault_database_secret_backend_connection.redis.name
  username            = "vault-static-user-1"
  rotation_period     = "360"
  rotation_statements = ["ACL SETUSER {{name}} on >{{password}} ~* +@all"]
}

# Define the dynamic Redis role
resource "vault_database_secret_backend_role" "redis_dynamic_role" {
  name    = "my-dynamic-role"
  backend = vault_mount.database.path
  db_name = "my-redis-database"

  creation_statements = [
    "[\"~*\", \"+@read\", \"+@write\", \"+@admin\"]"
  ]

  default_ttl = "1000"
  max_ttl     = "24000"
}


