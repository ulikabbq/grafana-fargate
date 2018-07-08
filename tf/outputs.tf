// lb dns
output "grafana_rds" {
  value = "${aws_rds_cluster.grafana.endpoint}"
}

output "grafana_bastion_ip" {
  value = "${aws_instance.bastion.public_ip}"
}

output "grafana_role" {
  value = "${aws_iam_role.grafana_assume.arn}"
}
