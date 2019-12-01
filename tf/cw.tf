// ECS Service AutoScaling Alarm
resource "aws_cloudwatch_metric_alarm" "grafana_service_high_cpu" {
  alarm_name          = "grafana-CPU-Utilization-High-40"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "40"

  dimensions = {
    ClusterName = aws_ecs_cluster.grafana.name
    ServiceName = aws_ecs_service.grafana.name
  }

  alarm_actions = [aws_appautoscaling_policy.service_up.arn]
}

resource "aws_cloudwatch_metric_alarm" "grafana_service_low_cpu" {
  alarm_name          = "grafana-CPU-Utilization-Low-29"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "5"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "29"

  dimensions = {
    ClusterName = aws_ecs_cluster.grafana.name
    ServiceName = aws_ecs_service.grafana.name
  }

  alarm_actions = [aws_appautoscaling_policy.service_down.arn]
}

resource "aws_appautoscaling_target" "service_scale_target" {
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.grafana.name}/${aws_ecs_service.grafana.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = var.grafana_count
  max_capacity       = 10

  depends_on = [aws_ecs_service.grafana]
}

resource "aws_appautoscaling_policy" "service_up" {
  name               = "grafana-scale-up"
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.grafana.name}/${aws_ecs_service.grafana.name}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 150
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 2
    }
  }

  depends_on = [aws_appautoscaling_target.service_scale_target]
}

resource "aws_appautoscaling_policy" "service_down" {
  name               = "grafana-scale-down"
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.grafana.name}/${aws_ecs_service.grafana.name}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 1500
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }

  depends_on = [aws_appautoscaling_target.service_scale_target]
}

