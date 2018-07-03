// lb dns
output "grafana_ecr" {
  value = "${aws_ecr_repository.grafana.repository_url}"
}

output "grafana_nginx_ecr" {
  value = "${aws_ecr_repository.grafana_nginx.repository_url}"
}
