data "template_file" "grafana" {
  template = "${file("${path.module}/task_definitions/grafana.json")}"

  vars {
    image_url        = "${var.image_url}"
    nginx_image_url  = "${var.nginx_image_url}"
    server_name      = "${var.dns_name}"
    log_group_region = "${var.aws_region}"
    log_group_name   = "${aws_cloudwatch_log_group.grafana.name}"
  }
}

resource "aws_ecs_cluster" "grafana" {
  name = "grafana"
}

resource "aws_ecr_repository" "grafana" {
  name = "grafana"
}

resource "aws_ecr_repository" "grafana_nginx" {
  name = "grafana_nginx"
}

resource "aws_ecs_task_definition" "grafana" {
  family                   = "grafana_task_definition"
  container_definitions    = "${data.template_file.grafana.rendered}"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 512
  memory                   = 1024
  task_role_arn            = "${aws_iam_role.grafana_ecs_task.arn}"
  execution_role_arn       = "${aws_iam_role.grafana_ecs_task_execution.arn}"
  network_mode             = "awsvpc"
}

resource "aws_ecs_service" "grafana" {
  name            = "grafana"
  cluster         = "${aws_ecs_cluster.grafana.name}"
  task_definition = "${aws_ecs_task_definition.grafana.arn}"
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = ["${aws_security_group.grafana_ecs.id}"]
    subnets         = ["${var.subnets}"]
  }

  load_balancer {
    target_group_arn = "${aws_lb_target_group.grafana.arn}"
    container_name   = "grafana_nginx"
    container_port   = 80
  }

  depends_on = ["aws_lb.grafana"]
}

resource "aws_cloudwatch_log_group" "grafana" {
  name = "grafana"
}

resource "aws_security_group" "grafana_ecs" {
  description = "ingress to the grafana fargate task from the alb"

  vpc_id = "${var.vpc_id}"
  name   = "grafana-ecs"

  //nginx
  ingress {
    protocol        = "tcp"
    from_port       = 80
    to_port         = 80
    security_groups = ["${aws_security_group.grafana_alb.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

