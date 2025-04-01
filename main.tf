provider "aws" {
  region = "us-west-2"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
}

# Public Subnets
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "PublicSubnet1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-west-2b"
  map_public_ip_on_launch = true
  tags = {
    Name = "PublicSubnet2"
  }
}

# Private Subnets
resource "aws_subnet" "private_subnet_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-west-2a"
  tags = {
    Name = "PrivateSubnet1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "us-west-2b"
  tags = {
    Name = "PrivateSubnet2"
  }
}

# 2. Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

# 3. ECS Cluster

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "ecs-cluster"
}

# 4. Security Group for ECS tasks (private subnet)

resource "aws_security_group" "ecs_security_group" {
  name        = "ecs_sg"
  description = "Allow access to ECS tasks"
  vpc_id      = aws_vpc.main.id
}

# 5. Elastic Load Balancer in Public Subnets

resource "aws_lb" "public_lb" {
  name               = "public-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ecs_security_group.id]
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
  enable_deletion_protection = false
  enable_cross_zone_load_balancing = true
  tags = {
    Name = "Public Load Balancer"
  }
}

# 6. ECS Task Definition (Simple example with a container)

resource "aws_ecs_task_definition" "ecs_task" {
  family                   = "my-task-family"
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  requires_compatibilities = ["EC2"]

  container_definitions = jsonencode([{
    name      = "my-app"
    image     = "ypahwa/python-web-server:latest"
    cpu       = 256
    memory    = 512
    essential = true
    portMappings = [
      {
        containerPort = 8080
        hostPort      = 8080
        protocol      = "tcp"
      }
    ]
  }])
}

# 7. ECS Service

resource "aws_ecs_service" "ecs_service" {
  name            = "my-ecs-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task.arn
  desired_count   = 1
  launch_type     = "EC2"

  network_configuration {
    subnets          = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
    security_groups = [aws_security_group.ecs_security_group.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.lb_target_group.arn
    container_name   = "my-app"
    container_port   = 8080
  }
}

# 8. Load Balancer Target Group

resource "aws_lb_target_group" "lb_target_group" {
  name     = "my-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

# 9. Load Balancer Listener

resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.public_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_target_group.arn
  }
}

