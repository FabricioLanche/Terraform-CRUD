terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# --- VPC y subnets (usa la default para simplificar) ---
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# --- Security Group para permitir tráfico HTTP ---
resource "aws_security_group" "crud_sg" {
  name        = "crud-sg"
  description = "Allow HTTP traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- ECS Cluster ---
resource "aws_ecs_cluster" "crud_cluster" {
  name = "crud-cluster"
}

# --- Task Definition ---
resource "aws_ecs_task_definition" "crud_task" {
  family                   = "crud-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.labrole_arn
  task_role_arn            = var.labrole_arn

  container_definitions = jsonencode([
    {
      name      = "crud-app"
      image     = var.app_image
      essential = true
      portMappings = [
        {
          containerPort = 8000
          hostPort      = 8000
        }
      ]
    }
  ])
}

# --- ECS Service ---
resource "aws_ecs_service" "crud_service" {
  name            = "crud-service"
  cluster         = aws_ecs_cluster.crud_cluster.id
  task_definition = aws_ecs_task_definition.crud_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    security_groups  = [aws_security_group.crud_sg.id]
    assign_public_ip = true
  }

  depends_on = [aws_ecs_task_definition.crud_task]
}

# --- Output de la URL pública ---
output "service_name" {
  value = aws_ecs_service.crud_service.name
}
