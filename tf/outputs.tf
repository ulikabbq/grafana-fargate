// lb dns
output "grafana_rds" {
  value = aws_rds_cluster.grafana.endpoint
}

output "grafana_role" {
  value = aws_iam_role.grafana_assume.arn
}

