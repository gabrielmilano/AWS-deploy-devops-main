provider "aws" {
  region      = "us-east-1"
}

resource "aws_vpc" "strapi_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "html-app-vpc"
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.strapi_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "strapi-public-subnet-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.strapi_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "strapi-public-subnet-2"
  }
}

resource "aws_internet_gateway" "strapi_igw" {
  vpc_id = aws_vpc.strapi_vpc.id
  tags = {
    Name = "strapi-igw"
  }
}

resource "aws_route_table" "strapi_public_rt" {
  vpc_id = aws_vpc.strapi_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.strapi_igw.id
  }
  tags = {
    Name = "strapi-public-rt"
  }
}

resource "aws_route_table_association" "strapi_public_rta_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.strapi_public_rt.id
}

resource "aws_route_table_association" "strapi_public_rta_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.strapi_public_rt.id
}

resource "aws_security_group" "strapi_alb_sg" {
  name        = "html-alb-sg"
  description = "Allow HTTP access to ALB for HTML app"
  vpc_id      = aws_vpc.strapi_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
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
    Name = "html-alb-sg"
  }
}

resource "aws_security_group" "strapi_ecs_sg" {
  name        = "html-ecs-sg"
  description = "Allow traffic from ALB to HTML app tasks"
  vpc_id      = aws_vpc.strapi_vpc.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.strapi_alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "html-ecs-sg"
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "strapi-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_task_role" {
  name = "strapi-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_ecs_cluster" "strapi_cluster" {
  name = "strapi-cluster"
  tags = {
    Name = "strapi-cluster"
  }
}

resource "aws_ecs_task_definition" "strapi_task" {
  family                   = "html-app-task-v7"
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name        = "html-app-container"
      image       = var.docker_image
      cpu         = 256
      memory      = 512
      essential   = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.strapi_logs.name
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }
      environment = []
    }
  ])
  tags = {
    Name = "html-app-task-definition-v4"
  }
}

resource "aws_ecs_service" "strapi_service" {
  name            = "html-app-service-v4"
  cluster         = aws_ecs_cluster.strapi_cluster.id
  task_definition = aws_ecs_task_definition.strapi_task.arn
  desired_count   = 1

  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
    security_groups = [aws_security_group.strapi_ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.strapi_tg.arn
    container_name   = "html-app-container"
    container_port   = 80
  }

  depends_on = [aws_lb_listener.strapi_http_listener]

  tags = {
    Name = "html-app-service-v2"
  }
}

resource "aws_lb" "strapi_alb" {
  name                       = "html-app-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.strapi_alb_sg.id]
  subnets                    = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]

  enable_deletion_protection = false

  tags = {
    Name = "html-app-alb"
  }
}

resource "aws_lb_target_group" "strapi_tg" {
  name        = "html-app-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.strapi_vpc.id
  target_type = "ip"
  
  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
  tags = {
    Name = "html-app-target-group"
  }
}

resource "aws_lb_listener" "strapi_http_listener" {
  load_balancer_arn = aws_lb.strapi_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.strapi_tg.arn
  }
  tags = {
    Name = "html-app-http-listener"
  }
}

resource "aws_cloudwatch_log_group" "strapi_logs" {
  name              = "/ecs/html-app"
  retention_in_days = 7

  tags = {
    Name = "html-app-log-group"
  }
}