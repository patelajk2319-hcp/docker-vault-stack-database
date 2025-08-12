locals {
  admin-role-name    = "${var.application-name}-dynamic-admin-role"
  readonly-role-name = "${var.application-name}-dynamic-readonly-role"
  static-role-name   = "${var.application-name}-static-role"

    existing-redis-users = [
    {
      username        = "vault-static-user-1"
      rotation_period = "1800" # 30min (must be in seconds)
      description     = "This user was already in Redis and now will be managed by Vault"
    },
    {
      username        = "vault-static-user-2"
      rotation_period = "3600" # 1hour (must be in seconds)
      description     = "This user was already in Redis and now will be managed by Vault"
    },
    {
      username        = "vault-static-user-3"
      rotation_period = "7200" # 2hours (must be in seconds)
      description     = "This user was already in Redis and now will be managed by Vault"
    }
  ]
}

