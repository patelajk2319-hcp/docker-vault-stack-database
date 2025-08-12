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

# Replace with your actual role-id and secret-id
vault write auth/approle/my-redis-application/login role_id=e4ea54ce-ae00-6300-1822-f3aad8ad962c secret_id=0fa152fe-8194-338c-76a4-78029df90440

#LOGIN INTO VAULT
vault write auth/approle//my-redis-application/login role_id=450d33b7-f33c-f810-ebae-1bb52c4c2ab3 secret_id=cbaa1a02-60ce-51f2-2bbb-61d5c8d659cf
vault login token=hvs.CAESIDB5SRShpyOPn6u8yr8_9a6eYhlpfZMV3n9p2AnxmoojGiEKHGh2cy5qdno5NXpkaGlPbWhaV2ozUncxQ1dJdksQuic