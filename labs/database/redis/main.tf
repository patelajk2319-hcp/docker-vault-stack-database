locals {
  admin-role-name    = "${var.application-name}-dynamic-admin-role"
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
  name          = var.database-name
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

module "dynamic_roles" {
  source             = "./modules/roles/dynamic/"
  readonly-role-name = local.readonly-role-name
  admin-role-name    = local.admin-role-name
  db-name            = vault_database_secret_backend_connection.redis.name
  mount-path         = vault_mount.database.path

  depends_on = [vault_database_secret_backend_connection.redis]
}

