provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = { Name = "auth-sso-vpc" }
}

resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true
  tags = { Name = "auth-sso-subnet" }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = { Name = "auth-sso-igw" }
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = { Name = "auth-sso-rt" }
}

resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}

resource "aws_security_group" "main" {
  vpc_id = aws_vpc.main.id
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
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
  tags = { Name = "auth-sso-sg" }
}

resource "aws_instance" "main" {
  ami                    = "ami-0f58b397bc5c1f2e8"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.main.id]
  iam_instance_profile   = "ec2-ecr-role"
  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    curl -sfL https://get.k3s.io | sh -
    sleep 60
    PASSWORD=$(aws ecr get-login-password --region ap-south-1)
    sudo kubectl create secret docker-registry ecr-secret \
      --docker-server=654654435115.dkr.ecr.ap-south-1.amazonaws.com \
      --docker-username=AWS \
      --docker-password=$PASSWORD
    sudo kubectl create deployment auth-sso-service \
      --image=654654435115.dkr.ecr.ap-south-1.amazonaws.com/auth-sso-service:latest \
      --port=8000
    sudo kubectl patch deployment auth-sso-service \
      -p '{"spec":{"template":{"spec":{"imagePullSecrets":[{"name":"ecr-secret"}]}}}}'
  EOF
  tags = { Name = "auth-sso-server" }
}