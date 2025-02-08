terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.aws_region
}

resource "aws_key_pair" "keySSH" {
  key_name   = var.key
  public_key = file("${var.key}.pub")
}

resource "aws_launch_template" "maquina" {
  image_id      = "ami-0606dd43116f5ed57"
  instance_type = var.instance
  key_name      = var.key

  tags = {
    Name = var.name_instance
  }
  security_group_names = [var.securityGroup]
  user_data            = var.isProduction ? filebase64("ansible.sh") : ""
}

resource "aws_default_vpc" "default" {

}

resource "aws_lb_target_group" "targetLB" {
  name     = "targetMachines"
  port     = "8000"
  protocol = "HTTP"
  vpc_id   = aws_default_vpc.default.id
  count    = var.isProduction ? 1 : 0
}

resource "aws_autoscaling_group" "grupo" {
  availability_zones = ["${var.aws_region}a", "${var.aws_region}b"]
  name               = var.groupName
  max_size           = var.max
  min_size           = var.min
  target_group_arns  = var.isProduction ? [aws_lb_target_group.targetLB[0].arn] : []
  launch_template {
    id      = aws_launch_template.maquina.id
    version = "$Latest"
  }
}

resource "aws_default_subnet" "subnet_1" {
  availability_zone = "${var.aws_region}a"
}

resource "aws_default_subnet" "subnet_2" {
  availability_zone = "${var.aws_region}b"
}

resource "aws_lb" "loadBalancer" {
  internal = false
  subnets  = [aws_default_subnet.subnet_1.id, aws_default_subnet.subnet_2.id]
  count    = var.isProduction ? 1 : 0
}

resource "aws_lb_listener" "inputLB" {
  load_balancer_arn = aws_lb.loadBalancer[0].arn
  port              = "8000"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.targetLB[0].arn
  }
  count = var.isProduction ? 1 : 0
}

resource "aws_autoscaling_policy" "production-scaling" {
  name                   = "terrafrom-scaling"
  autoscaling_group_name = aws_autoscaling_group.grupo.name
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }
  count = var.isProduction ? 1 : 0
}
