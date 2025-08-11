vault write database/roles/my-dynamic-role \
    db_name="my-redis-database" \
    creation_statements='["~*", "+@read","+@write"]' \
    default_ttl="1h" \
    max_ttl="2h"


vault write -force database/rotate-root/my-redis-database

#CREATES A USER AGAINS THIS ROLE - THE ROLE WILL HAVE CREATION STATEMENT
vault read database/creds/my-dynamic-role

vault read database/static-roles/my-static-role # This will reveal the password for the statis creds in this role

#ROTATE THE ROOT TOKEN FOR DATABASE
vault read database/rotate-root/my-redis-database

vault read database/static-creds/my-static-role

#REDIS
AUTH vault-dynamic-user SuperSecretPass123
AUTH vault-static-user-1 SuperSecretPass123