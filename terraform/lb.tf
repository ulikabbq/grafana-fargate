resource "aws_lb" "grafana" {
  name            = "${var.resource_prefix}-grafana"
  internal        = "false"
  security_groups = [var.grafana_alb_security_group_id]
  subnets         = var.lb_subnets
  idle_timeout    = "3600"

  enable_deletion_protection = false

  tags = {
    Name        = "${var.resource_prefix}-grafana"
    Description = "Application Load Balancer for Grafana"
    ManagedBy   = "Terraform"
  }
}

resource "aws_lb_listener" "front_end_http" {
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
}

resource "aws_lb_listener" "front_end_https" {
  load_balancer_arn = aws_lb.grafana.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = var.cert_arn

  default_action {
    target_group_arn = aws_lb_target_group.grafana.arn
    type             = "forward"
  }
}

resource "aws_lb_target_group" "grafana" {
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

  tags = {
    Name        = "${var.resource_prefix}-grafana-tg"
    Description = "Target Group for Grafana"
    ManagedBy   = "Terraform"
  }
}
