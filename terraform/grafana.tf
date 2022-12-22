locals {
  grafana_config = {
    GF_SERVER_DOMAIN     = "${var.grafana_subdomain}.${var.dns_name}"
    GF_DATABASE_USER     = var.grafana_db_username
    GF_DATABASE_TYPE     = "mysql"
    GF_DATABASE_HOST     = "${aws_rds_cluster.grafana.endpoint}:3306"
    GF_LOG_LEVEL         = var.grafana_log_level
    GF_DATABASE_PASSWORD = random_password.password.result
    ### AUTH
    GF_AUTH_GENERIC_OAUTH_ENABLED               = true
    GF_AUTH_GENERIC_OAUTH_ALLOW_SIGN_UP         = false
    GF_AUTH_GENERIC_OAUTH_TEAM_IDS              = ""
    GF_AUTH_GENERIC_OAUTH_ALLOWED_ORGANIZATIONS = ""
    GF_AUTH_GENERIC_OAUTH_NAME                  = var.oauth_name
    GF_AUTH_GENERIC_OAUTH_CLIENT_ID             = var.oauth_client_id
    GF_AUTH_GENERIC_OAUTH_CLIENT_SECRET         = var.oauth_client_secret
    GF_AUTH_GENERIC_OAUTH_SCOPES                = "openid profile email"
    GF_AUTH_GENERIC_OAUTH_AUTH_URL              = "${var.oauth_domain}/authorize"
    GF_AUTH_GENERIC_OAUTH_TOKEN_URL             = "${var.oauth_domain}/oauth/token"
    GF_AUTH_GENERIC_OAUTH_API_URL               = "${var.oauth_domain}/userinfo"
    GF_AUTH_GENERIC_OAUTH_USE_PKCE              = true
  }
}
resource "aws_ecs_cluster" "grafana" {
  name = "${var.resource_prefix}-grafana"
}

resource "aws_ecr_repository" "grafana" {
  name = "${var.resource_prefix}-grafana"
}

resource "aws_ecs_task_definition" "grafana" {
  family = "${var.resource_prefix}-grafana_task_definition"
  container_definitions = jsonencode([
    {
      name      = "${var.resource_prefix}-grafana"
      image     = var.image_url
      essential = true
      portMappings = [
        {
          hostPost      = 3000
          containerPort = 3000
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.grafana.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "${var.resource_prefix}-grafana"
        }
      }
      environment = [
        for key in keys(local.grafana_config) :
        {
          name  = key,
          value = lookup(local.grafana_config, key)
        }
      ]
    }
  ])
  requires_compatibilities = ["FARGATE"]
  cpu                      = 512
  memory                   = 1024
  task_role_arn            = aws_iam_role.grafana_ecs_task.arn
  execution_role_arn       = aws_iam_role.grafana_ecs_task_execution.arn
  network_mode             = "awsvpc"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_ecs_service" "grafana" {
  name            = "${var.resource_prefix}-grafana"
  cluster         = aws_ecs_cluster.grafana.name
  task_definition = aws_ecs_task_definition.grafana.arn
  desired_count   = var.grafana_count
  launch_type     = "FARGATE"

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200


  network_configuration {
    security_groups = [aws_security_group.grafana_ecs.id]
    subnets         = var.subnets
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.grafana.arn
    container_name   = "${var.resource_prefix}-grafana"
    container_port   = 3000
  }

  depends_on = [aws_lb.grafana]

  lifecycle {
    ignore_changes = [desired_count]
  }
}

resource "aws_cloudwatch_log_group" "grafana" {
  name = "${var.resource_prefix}-grafana"
}

resource "aws_security_group" "grafana_ecs" {
  description = "ingress to the grafana fargate task from the alb"

  vpc_id = var.vpc_id
  name   = "${var.resource_prefix}-grafana-ecs"

  //nginx
  ingress {
    protocol        = "tcp"
    from_port       = 3000
    to_port         = 3000
    security_groups = [aws_security_group.grafana_alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

