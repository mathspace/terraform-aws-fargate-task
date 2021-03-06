variable "name" {
  description = "Name of the Fargate task and related resources"
  type        = string
}

variable "cluster_name" {
  description = "Name of the Fargate cluster"
  type        = string
  default     = "default"
}

variable "image_repository_url" {
  description = "AWS ECR repository URL for the Docker image to use"
  type        = string
}

variable "image_tag" {
  description = "Image tag of the Docker image to use"
  type        = string
}

variable "cpu" {
  description = "CPU allocation, see https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html"
  type        = string
  default     = "256"
}

variable "memory" {
  description = "Memory allocation, see https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html"
  type        = string
  default     = "512"
}

variable "desired_count" {
  description = "Number of desired running tasks, or 0 to run only when manually invoked"
  type        = string
  default     = "0"
}

variable "subnets" {
  description = "VPC subnets to assign to the task"
  type        = list(string)
}

variable "security_groups" {
  description = "VPC security groups to assign to the task"
  type        = list(string)
}

variable "environment" {
  description = "Environment variables passed into the task at runtime"
  type        = map(string)
  default     = {}
}

variable "secrets" {
  description = "Secret environment variables to be read from Parameter Store and Secrets Manager"
  type        = map(string)
  default     = {}
}

