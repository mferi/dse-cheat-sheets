### Check AWS CLI installation
> aws help

### Set up AWS CLI
> aws configure

### s3
> aws s3api create-bucket --bucket ,bucket_name>
> aws s3 cp

### ECS
##### Scheduler
1. Services: long lived (always running) and stateless (no state)
2. RunTask: run for a certain amount of time, on demand
3. StartTask: allow you to start a task on an specific instance

##### ECS cluster
> aws ecs create-cluster --cluster-name <cluster_name>
> aws ecs list-clusters
> aws ecs describe-clusters --clusters <cluster_name>
> aws ecs delete-cluster --cluster-name <cluster_name>

##### ECS container instance - life cycle
cycle state: active and connected/active and disconnected/inactive
> aws ec2 run-intances --image-id ami-2b3b6041 --count 1 --instance-type t2.micro --iam-instance-profile Name=<ecsInstanceRole> --key-name <key> --security-group-ids <sg> --user-data <config>
> aws ec2 describe-instance-status --instance-id <i_id>
> aws ecs list-container-intances --cluster <cluster_name>
> aws ecs describe-container --cluster <cluster_name> --container-instances <c_i>
> aws ec2 terminate-intances --intances-ids <i_id>

##### ECS Task definitions
Family, container definitions (cpu...), volumes
> aws ecs register-task-definition --cli-input-json file://<file_name>
> aws ecs list-task-definition-families
> aws ecs list-task-definitions
> aws ecs describe-task-definition --task-definition <family_name>:<family_number>
> aws ecs deregister-task-definition --task-definition <family_name>:<family_number>
> aws ecs register-task-definition --generate-cli-skeleton

### AWS Lambda
Update lambda fuction code
> aws lambda update-function-code --function-name <function_name> --zip-file fileb://<file_name.zip>  #load as binary, not text or UTF

Publish lambda version
> aws lambda publish-version --function-name <function_name>

Update lambda configuration
> aws lambda update-function-configuration --function-name <function_name> --handler <handler_name>.handler

Asign an alias to a function version
>aws lambda update-alias --function-name <function_name> --function-version <int> --name <alias_or_tag_name>
