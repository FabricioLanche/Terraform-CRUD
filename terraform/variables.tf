variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "aws_account_id" {
  type        = string
  description = "AWS account ID"
}

variable "ecs_cluster_name" {
  type        = string
  description = "Name of the ECS cluster"
  default     = "fastapi-sqlite-cluster"
}

variable "ecs_service_name" {
  type        = string
  description = "Name of the ECS service"
  default     = "fastapi-sqlite-service"
}

variable "image_tag" {
  type        = string
  description = "Docker image tag"
  default     = "latest"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for the ECS service"
  default     = []
}

variable "security_group_ids" {
  type        = list(string)
  description = "List of security group IDs for the ECS service"
  default     = []
}