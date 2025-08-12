resource "vault_database_secret_backend_static_role" "redis_static_users" {
  for_each = { for user in var.existing-redis-users : user.username => user }

  backend         = var.mount-path
  name            = each.value.username
  db_name         = var.db-name
  username        = each.value.username
  rotation_period = each.value.rotation_period
}


resource "vault_policy" "redis-reader" {
  for_each = { for user in var.existing-redis-users : user.username => user }
  
  name = "redis-${each.value.username}-reader"

  policy = <<EOT
# Allow reading static credentials for ${each.value.username}
path "database/redis/my-redis-application/${each.value.username}" {
  capabilities = ["read"]
}

# Allow listing to see available credentials
path "database/redis/my-redis-application" {
  capabilities = ["list"]
}
EOT
}
