#Enable AppRole Authentication Method on a path
vault auth enable -path=approle/my-redis-application approle

vault write auth/approle/my-redis-application/role/vault-static-user-1-role \
    token_type=service \
    secret_id_ttl=60m \
    token_ttl=20m \
    token_max_ttl=30m \
    token_policies=redis-vault-static-user-1-reader-policy
    secret_id_num_uses=40 \
    bind_secret_id=true

#Read Role
vault read auth/approle/my-redis-application/role/vault-static-user-1-role
#Delete the Role
vault delete auth/approle/my-redis-application/role/vault-static-user-1-role

#Create  SECRET
vault write -f auth/approle/my-redis-application/role/vault-static-user-1-role/secret-id

# GET THE ROLE ID
vault read auth/approle/my-redis-application/role/vault-static-user-1-role/role-id

#LOGIN INTO VAULT
vault write auth/approle//my-redis-application/login role_id=e4ea54ce-ae00-6300-1822-f3aad8ad962c secret_id=57b623ae-6c03-f4b7-964e-955c543904d9
vault login token=hvs.CAESIJ8VVbdOePVi2Nc1jIpZ_BGzbYCm2YYvVvEW7mjvdhNEGiIKHGh2cy5mUW1SOXJhZDl6b0M1Y1lnMXh2T0tkOXAQ0qIB