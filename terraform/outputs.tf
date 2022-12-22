// lb dns
output "grafana_rds" {
  value = aws_rds_cluster.grafana.endpoint
}

output "grafana_role" {
  value = aws_iam_role.grafana_assume.arn
}

output "grafana_ecs_sg" {
  value = aws_security_group.grafana_ecs.id
}

