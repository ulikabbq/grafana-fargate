resource "aws_lb" "grafana" {
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb
  name            = "${var.resource_prefix}-grafana"
  internal        = "false"
  security_groups = [var.grafana_alb_security_group_id]
  subnets         = var.lb_subnets
  idle_timeout    = "3600"

  enable_deletion_protection = false

  tags = var.common_tags
}

resource "aws_lb_listener" "front_end_http" {
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener
  load_balancer_arn = aws_lb.grafana.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
  tags = var.common_tags
}

resource "aws_lb_listener" "front_end_https" {
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener
  load_balancer_arn = aws_lb.grafana.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = var.cert_arn

  default_action {
    target_group_arn = aws_lb_target_group.grafana.arn
    type             = "forward"
  }
  tags = var.common_tags
}

resource "aws_lb_target_group" "grafana" {
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group
  name                 = "${var.resource_prefix}-grafana-tg"
  port                 = 3000
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  target_type          = "ip"
  deregistration_delay = 30

  health_check {
    interval            = 10
    path                = "/login"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    protocol            = "HTTP"
  }

  tags = var.common_tags
}
