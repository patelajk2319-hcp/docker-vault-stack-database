#LIST ALL ROLES ON THE MOUNT
vault list database/redis/my-redis-application/roles

#READ THE ROLE
vault read database/redis/my-redis-application/roles/my-redis-application-dynamic-admin-role

vault read database/redis/my-redis-application/roles/my-redis-application-dynamic-readonly-role

#CREATE CREDS AGAINST EACH ROLE

vault read database/redis/my-redis-application/creds/my-redis-application-dynamic-admin-role

vault read database/redis/my-redis-application/creds/my-redis-application-dynamic-readonly-role


# VIEW ALL cuurnet leases 
vault list  -format=json /sys/leases/lookup/database/redis/my-redis-application/creds/role | jq -r '.[]' | xargs -I {} vault lease lookup  database/redis/my-redis-application/creds/role/{}

# MIGHT HAVE TO FORCE IF LEASES STILL EXIST
vault lease revoke -force database/redis/creds/redis-dynamic-role/<leaseid>
vault lease revoke -force -prefix database/
vault lease revoke -force -prefix database/redis
