#LIST ALL ROLES ON THE MOUNT
vault list database/redis/roles

#READ THE ROLE
vault read database/redis/roles/redis-dynamic-role

vault read database/redis/roles/redis-dynamic-admin-role

vault read database/redis/roles/redis-dynamic-readonly-role

#CREATE CREDS AGAINST EACH ROLE

vault read database/redis/creds/redis-dynamic-role

vault read database/redis/creds/redis-dynamic-readonly-role 

vault read database/redis/creds/redis-dynamic-admin-role