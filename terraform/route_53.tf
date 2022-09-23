resource "aws_route53_record" "grafana" {
  zone_id = var.dns_zone
  name    = "grafana"
  type    = "A"

  alias {
    name                   = aws_lb.grafana.dns_name
    zone_id                = aws_lb.grafana.zone_id
    evaluate_target_health = false
  }
}

