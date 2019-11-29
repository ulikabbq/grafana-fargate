data "aws_ssm_parameter" "rds_master_password" {
  name            = "/grafana/GF_DATABASE_PASSWORD"
  with_decryption = "true"
}

resource "aws_ssm_parameter" "GF_SERVER_ROOT_URL" {
  name  = "/grafana/GF_SERVER_ROOT_URL"
  type  = "String"
  value = "https://${var.dns_name}"
}

resource "aws_ssm_parameter" "GF_LOG_LEVEL" {
  name  = "/grafana/GF_LOG_LEVEL"
  type  = "String"
  value = "INFO"
}

resource "aws_ssm_parameter" "GF_INSTALL_PLUGINS" {
  name  = "/grafana/GF_INSTALL_PLUGINS"
  type  = "String"
  value = "grafana-worldmap-panel,grafana-clock-panel,jdbranham-diagram-panel,natel-plotly-panel"
}

resource "aws_ssm_parameter" "GF_DATABASE_USER" {
  name  = "/grafana/GF_DATABASE_USER"
  type  = "String"
  value = "root"
}

resource "aws_ssm_parameter" "GF_DATABASE_TYPE" {
  name  = "/grafana/GF_DATABASE_TYPE"
  type  = "String"
  value = "mysql"
}

resource "aws_ssm_parameter" "GF_DATABASE_HOST" {
  name  = "/grafana/GF_DATABASE_HOST"
  type  = "String"
  value = "${aws_rds_cluster.grafana.endpoint}:3306"
}

