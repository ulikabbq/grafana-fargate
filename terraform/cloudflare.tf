terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.6.0"
    }
  }
}

resource "cloudflare_record" "record" {
  zone_id         = var.cloudflare_zone_id
  name            = var.cloudflare_record_name
  type            = "CNAME"
  value           = aws_lb.grafana.dns_name
  ttl             = 1
  proxied         = true
  allow_overwrite = true
  tags            = var.cloudflare_record_tags
}
