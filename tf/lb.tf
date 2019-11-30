resource "aws_lb" "grafana" {
  name            = "grafana"
  internal        = "false"
  security_groups = [aws_security_group.grafana_alb.id]
  subnets         = var.lb_subnets
  idle_timeout    = "3600"

  enable_deletion_protection = false

  tags = {
    Name        = "grafana"
    Description = "Application Load Balancer for Grafana"
    ManagedBy   = "Terraform"
  }
}

resource "aws_lb_listener" "front_end_http" {
  load_balancer_arn = aws_lb.grafana.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.grafana.arn
    type             = "forward"
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
  name                 = "grafana-tg"
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
    Name        = "grafana-tg"
    Description = "Target Group for Grafana"
    ManagedBy   = "Terraform"
  }
}

resource "aws_security_group" "grafana_alb" {
  description = "the alb security group that allows port 80/443 from whitelisted ips"

  vpc_id = var.vpc_id
  name   = "grafana-alb"

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = var.whitelist_ips
  }

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = var.whitelist_ips
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

