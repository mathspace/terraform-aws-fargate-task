terraform {
  required_version = ">=1"
}

data "aws_region" "region" {
}

locals {
  log_group_name = "/aws/ecs/${var.cluster_name}/${var.name}"

  definition_json_inputs = {
    name                 = var.name
    image_repository_url = var.image_repository_url
    image_tag            = var.image_tag
    log_group            = local.log_group_name
    region               = data.aws_region.region.name
    environment          = var.environment
    secrets              = var.secrets
  }
}

data "external" "definition_json" {
  program = ["${path.module}/definition.sh", jsonencode(local.definition_json_inputs)]
}

resource "aws_ecs_task_definition" "ecs_task" {
  family                   = var.name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  container_definitions    = data.external.definition_json.result["rendered"]

  # Gives the Docker agent permission to ECR and CloudWatch logs
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  # Gives the task container permission to AWS resources
  task_role_arn = aws_iam_role.ecs_task_role.arn

  # See docs for acceptable values for cpu and memory:
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html

  cpu    = var.cpu
  memory = var.memory
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.cluster_name
}

resource "aws_ecs_service" "ecs_service" {
  name            = var.name
  cluster         = aws_ecs_cluster.ecs_cluster.id
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.ecs_task.arn
  desired_count   = var.desired_count

  network_configuration {
    subnets         = var.subnets
    security_groups = var.security_groups
  }
}

resource "aws_cloudwatch_log_group" "log_group" {
  name              = local.log_group_name
  retention_in_days = 30

  tags = {
    Name = var.name
  }
}
