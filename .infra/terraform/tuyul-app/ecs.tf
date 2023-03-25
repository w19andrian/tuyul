data "aws_secretsmanager_secret" "docker_hub" {
  name = var.dockerhub_secret_name
}

data "docker_image" "this" {
  name = local.image_name
}

resource "aws_ecs_task_definition" "this" {
  family                   = "${var.app_name}-${var.env}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  container_definitions = jsonencode([
    {
      name  = local.full_app_name
      image = data.docker_image.this.repo_digest
      repositoryCredentials = {
        credentialsParameter = data.aws_secretsmanager_secret.docker_hub.arn
      }
      cpu          = 256
      memory       = 512
      network_mode = "awsvpc"
      essential    = true
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.app_logger.id
          awslogs-region        = var.region
          awslogs-stream-prefix = local.full_app_name
        }
      }
      environment = [
        {
          name  = "TUYUL_ADDR"
          value = "0.0.0.0"
        },
        {
          name  = "REDIS_TLS_ENABLED"
          value = "TRUE"
        },
        {
          name  = "TUYUL_PORT"
          value = tostring(var.container_port)
        },
        {
          name  = "REDIS_ADDR"
          value = data.terraform_remote_state.core.outputs.redis_endpoint
        },
        {
          name  = "REDIS_USER"
          value = data.terraform_remote_state.core.outputs.redis_username
        },
        {
          name  = "REDIS_PASSWD"
          value = data.terraform_remote_state.core.outputs.redis_password
        }
      ]
    }
  ])

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  execution_role_arn = aws_iam_role.this.arn
  task_role_arn      = aws_iam_role.this.arn

  tags = local.user_def_tags
}

resource "aws_cloudwatch_log_group" "app_logger" {
  name = "${local.full_app_name}-logs"

  tags = local.user_def_tags
}

resource "aws_ecs_service" "this" {
  name                              = local.full_app_name
  cluster                           = data.terraform_remote_state.core.outputs.ecs_cluster_id
  task_definition                   = aws_ecs_task_definition.this.arn
  desired_count                     = var.desired_instance_count
  propagate_tags                    = "NONE"
  health_check_grace_period_seconds = 0
  force_new_deployment              = true

  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    base              = 1
    weight            = 100
  }

  network_configuration {
    subnets          = data.terraform_remote_state.core.outputs.vpc_private_subnets
    assign_public_ip = false

    security_groups = [
      aws_security_group.allow_http.id,
      aws_security_group.allow_https.id,
      aws_security_group.ecs_service.id,
      data.terraform_remote_state.core.outputs.redis_security_group
    ]
  }
  deployment_controller {
    type = "ECS"
  }

  deployment_circuit_breaker {
    enable   = false
    rollback = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = local.full_app_name
    container_port   = var.container_port
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
  tags = local.user_def_tags
}
