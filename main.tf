terraform {
     required_providers {
       aws = {
         source  = "hashicorp/aws"
         version = "~> 5.0"
       }
     }
   }

   provider "aws" {
     region = "eu-west-1"
   }

   resource "aws_s3_bucket" "first_bucket" {
     bucket = "your-name-terraform-demo-2026"
   }

resource "aws_vpc" "lab_platform_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "lab-platform-vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.lab_platform_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "lab-platform-public-subnet"
  }
}
resource "aws_subnet" "public_subnet_b" {
  vpc_id                  = aws_vpc.lab_platform_vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "eu-west-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "lab-platform-public-subnet-b"
  }
}
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.lab_platform_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-west-1a"

  tags = {
    Name = "lab-platform-private-subnet"
  }
}

resource "aws_internet_gateway" "lab_platform_igw" {
  vpc_id = aws_vpc.lab_platform_vpc.id

  tags = {
    Name = "lab-platform-igw"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.lab_platform_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab_platform_igw.id
  }

  tags = {
    Name = "lab-platform-public-rt"
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}
resource "aws_route_table_association" "public_subnet_b_association" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_route_table.id
}
resource "aws_security_group" "web_sg" {
  name        = "lab-platform-web-sg"
  description = "Allow HTTP traffic to web instances"
  vpc_id      = aws_vpc.lab_platform_vpc.id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
ingress {
    description = "SSH for debugging via EC2 Instance Connect"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["80.233.52.234/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "lab-platform-web-sg"
  }
}
resource "aws_launch_template" "web_launch_template" {
  name_prefix   = "lab-platform-web-"
  image_id      = "ami-0c1c30571d2dae5c9"
  instance_type = "t3.micro"

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = filebase64("${path.module}/app/user_data.sh")

  tags = {
    Name = "lab-platform-web-launch-template"
  }
}
resource "aws_autoscaling_group" "web_asg" {
  desired_capacity   = 2
  min_size           = 1
  max_size           = 3
  vpc_zone_identifier = [aws_subnet.public_subnet.id]
  target_group_arns = [aws_lb_target_group.web_tg.arn]

  launch_template {
    id      = aws_launch_template.web_launch_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "lab-platform-web-instance"
    propagate_at_launch = true
  }
}
resource "aws_lb" "web_alb" {
  name               = "lab-platform-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_sg.id]
  subnets            = [aws_subnet.public_subnet.id, aws_subnet.public_subnet_b.id]

  tags = {
    Name = "lab-platform-alb"
  }
}

resource "aws_lb_target_group" "web_tg" {
  name     = "lab-platform-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.lab_platform_vpc.id

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 10
  }

  tags = {
    Name = "lab-platform-tg"
  }
}

resource "aws_lb_listener" "web_listener" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}
