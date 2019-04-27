output "ecs_cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = "${aws_ecs_cluster.ecs_cluster.arn}"
}

output "ecs_service_arn" {
  description = "ARN of the ECS service"
  value       = "${aws_ecs_service.ecs_service.id}"
}

output "task_definition_arn" {
  description = "ARN of the ECS task definition"
  value       = "${aws_ecs_task_definition.ecs_task.arn}"
}

output "task_execution_role_arn" {
  description = "ARN of the ECS task execution role"
  value       = "${aws_iam_role.ecs_task_execution_role.arn}"
}

output "task_role_arn" {
  description = "ARN of the ECS task role"
  value       = "${aws_iam_role.ecs_task_role.arn}"
}

output "ecs_task_role_id" {
  description = "ID for the ECS task role, to attach a custom policy"
  value       = "${aws_iam_role.ecs_task_role.id}"
}

output "log_group_name" {
  description = "CloudWatch log group used for logging"
  value       = "${local.log_group_name}"
}
