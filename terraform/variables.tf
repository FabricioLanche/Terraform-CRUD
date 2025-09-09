variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "app_image" {
  description = "Docker image to deploy in ECS"
  type        = string
}

variable "labrole_arn" {
  description = "IAM Role ARN for ECS execution"
  type        = string
}
