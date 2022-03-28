This operator was created with `operator-sdk` (https://sdk.operatorframework.io/docs/building-operators/ansible/tutorial/)

## Overview

Creates `postgres.db.zmrzlina.hu` and `postgresuser.db.zmrzlina.hu` CR.

The `Makefile` containts a `VERSION` variable which needs to be updated (or overridden) when a new artifact is built.


## How to

### build and push the image

Using `latest` is useful for development.
```
VERSION=latest make docker-build docker-push
```

Make the deployment reload the latest image:
```
k -n ext-postgres-op-system rollout restart deployment ext-postgres-op-controller-manager
```

Watch operator logs:
```
k -n ext-postgres-op-system logs deploy/ext-postgres-op-controller-manager manager -f
```

### Deploy the operator
(under normal circumstances this is done by Terraform somewhere else)
```
VERSION=latest make deploy
```

redeploy the whole thing in one command
```
VERSION=latest make undeploy deploy
```

### Run ansible locally for testing

Use `make tunnel-backend-db` or `kubectl port-forward deployment/zh-ambassador-app-db 15432` to make the db port available on localhost.

this would create the db with the RW user
```
ansible-playbook local.yaml --extra-vars "database_name=dev-op-1 secret_name_prefix=zh-db- k8s_namespace=zh-app-test-quick-1 pg_server_login_host=localhost pg_server_login_user=rdsroot pg_server_login_password=xxxx pg_server_login_port=15432 privileges=RW" --extra-vars='{"extensions": [postgis,citext]}' -vv
```

in order to create an RO user run this
```
ansible-playbook local.yaml --extra-vars "database_name=dev-op-1 secret_name_prefix=zh-db- k8s_namespace=zh-app-test-quick-1 pg_server_login_host=localhost pg_server_login_user=rdsroot pg_server_login_password=xxxx pg_server_login_port=15432 privileges=RO database_user_name=dev_op_1_ro" --extra-vars='{"extensions": [postgis,citext]}' -vv
```

## CRD examples

*Note: the operator replaces dashes with underscores in names.*

```
apiVersion: db.zmrzlina.hu/v1alpha1
kind: Postgres
metadata:
  name: testdb-1
spec:
  database_name: testdb-1
  extensions:
    - postgis
    - citext
```

```
apiVersion: db.zmrzlina.hu/v1alpha1
kind: PostgresUser
metadata:
  name: testdb-1
spec:
  database_name: testdb-1
  secret_name_prefix: zh-db-
  privileges: RW
```

```
apiVersion: db.zmrzlina.hu/v1alpha1
kind: PostgresUser
metadata:
  name: testdb-1-ro
spec:
  database_name: testdb-1
  secret_name_prefix: zh-db-
  database_user_name: testdb-1_ro
  privileges: RO
```
