# 特定のAWS ECSタスクをFargateで実行するためのスクリプト

```
# run-task-production.bash

#!/bin/bash

TASK_DEFINITION=$1

aws ecs run-task \
  --cluster "..." \
  --task-definition "$TASK_DEFINITION" \
  --launch-type "FARGATE" \
  --network-configuration "awsvpcConfiguration={subnets=[subnet-..., subnet-...],securityGroups=[sg-...],assignPublicIp=DISABLED}" \
  --profile ...
```

```
$ run-task-production.bash #{task-name}
```
