# Data sources para obtener la AMI más reciente y VPC por defecto
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_security_group" "fastapi_sg" {
  name_prefix = "fastapi-sg-"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "FastAPI Port"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "fastapi-security-group"
  }
}

resource "aws_instance" "fastapi_instance" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.fastapi_sg.id]
  subnet_id              = data.aws_subnets.default.ids[0]

  key_name = var.key_pair_name

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    docker_image = "raczaz/terraform-crud:${var.image_tag}"
    app_port     = 8000
  }))

  tags = {
    Name = var.instance_name
  }

  lifecycle {
    create_before_destroy = true
  }
}