# terraform-aws-fargate-task

Terraform module to run a Docker image as an AWS Fargate task

## Requirements

- Docker
- md5sum (e.g. from `brew install md5sha1sum`)
- jq (e.g. from `brew install jq`)

## Usage

See [examples](examples).

Use [run_fargate_task.sh](run_fargate_task.sh) to run Fargate tasks manually.

## Inputs

| Name                 | Description                                                                                                   |  Type  | Default | Required |
| -------------------- | ------------------------------------------------------------------------------------------------------------- | :----: | :-----: | :------: |
| cpu                  | CPU allocation, see https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html    | string | `"256"` |    no    |
| desired_count        | Number of desired running tasks, or 0 to run only when manually invoked                                       | string |  `"0"`  |    no    |
| environment          | Environment variables passed into the task at runtime                                                         |  map   | `<map>` |    no    |
| image_repository_url | AWS ECR repository URL for the Docker image to use                                                            | string |   n/a   |   yes    |
| image_tag            | Image tag of the Docker image to use                                                                          | string |   n/a   |   yes    |
| memory               | Memory allocation, see https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html | string | `"512"` |    no    |
| name                 | Name of the Fargate task and related resources                                                                | string |   n/a   |   yes    |
| security_groups      | VPC security groups to assign to the task                                                                     |  list  |   n/a   |   yes    |
| subnets              | VPC subnets to assign to the task                                                                             |  list  |   n/a   |   yes    |

## Outputs

| Name             | Description                                         |
| ---------------- | --------------------------------------------------- |
| ecs_cluster_arn  | ARN of the ECS cluster                              |
| ecs_service_arn  | ARN of the ECS service                              |
| ecs_task_role_id | ID for the ECS task role, to attach a custom policy |
| log_group_name   | CloudWatch log group used for logging               |
