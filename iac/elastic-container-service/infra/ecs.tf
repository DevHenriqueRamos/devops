# module "ecs" {
#   source = "terraform-aws-modules/ecs/aws"

#   cluster_name       = var.environment
#   container_insights = true
#   capacity_providers = ["FARGATE"]
#   default_capacity_provider_use_fargate = [
#     {
#       capacity_provider = "FARGATE"
#     }
#   ]
# }

module "ecs" {
  source = "terraform-aws-modules/ecs/aws"

  cluster_name = var.environment

  cluster_configuration = {
    execute_command_configuration = {
    }
  }

  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 1
      }
    }
  }
}

resource "aws_ecs_task_definition" "Django-API" {
  family                   = "Django-API"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.role.arn
  container_definitions = jsonencode(
    [
      {
        name      = "producao"
        image     = "329599629292.dkr.ecr.us-west-2.amazonaws.com/producao:latest"
        cpu       = 256
        memory    = 512,
        essential = true
        portMappings = [
          {
            containerPort = 8000,
            hostPort      = 8000
          }
        ]
      }
    ]
  )
}

resource "aws_ecs_service" "Django-API" {

  depends_on = [aws_lb_target_group.target]

  name            = "Django-API"
  cluster         = module.ecs.cluster_id
  desired_count   = 1
  task_definition = aws_ecs_task_definition.Django-API.arn

  load_balancer {
    target_group_arn = aws_lb_target_group.target.arn
    container_name   = "producao"
    container_port   = 8000
  }

  network_configuration {
    subnets          = module.vpc.private_subnets
    security_groups  = [aws_security_group.private.id]
    assign_public_ip = true
  }

  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
  }
}
