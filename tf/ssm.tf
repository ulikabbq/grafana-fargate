data "aws_ssm_parameter" "rds_master_password" {
  name            = "/grafana/GF_DATABASE_PASSWORD"
  with_decryption = "true"
}

#resource "aws_ssm_parameter" "GF_INSTALL_PLUGINS" {
#  name  = "/grafana/GF_INSTALL_PLUGINS"
#  type  = "String"
#  value = "grafana-worldmap-panel,grafana-clock-panel,jdbranham-diagram-panel,natel-plotly-panel"
#}



