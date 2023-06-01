variable "region" {
  default     = "us-east-1"
  description = "The primary AWS region"
}

variable "resource_prefix" {
  description = "A prefix to add to resource names. e.g. integration-<resource-name>"
  type        = string
}

variable "account_id" {
  default = ""
}

variable "grafana_alb_security_group_id" {
  description = "id of the security group for the Grafana alb"
}

variable "grafana_ecs_security_group_id" {
  description = "id of the security group for the Grafana ecs"
}

variable "dns_zone" {
  description = "the Route 53 ZoneId"
}

variable "dns_name" {
  description = "The DNS name for the zone"
  default     = ""
}

variable "grafana_subdomain" {
  description = "The subdomain to use for Grafana. <grafana_subdomain>.<dns_name>"
  type        = string
}

variable "cert_arn" {
  description = "the certificate arn that is associated with the dns_name"
  default     = ""
}

variable "vpc_id" {
  description = "The vpc id where grafana will be deployed"
  default     = ""
}

variable "subnets" {
  description = "the subnets used for the grafana task"
  default     = [""]
}

variable "lb_subnets" {
  description = "the load balancer subnets"
  default     = [""]
}

variable "db_subnet_ids" {
  description = "the subnets to launch the Aurora databse"
  default     = [""]
}

variable "db_instance_type" {
  description = "the instance size for the Aurora database"
  default     = "db.t2.small"
}

variable "image_url" {
  description = "the image url for the grafana image"
  default     = "grafana/grafana:8.2.6"
}

variable "grafana_count" {
  default = "1"
}

variable "grafana_db_username" {
  type        = string
  description = "The username to use for the Grafana db backend"
}

variable "grafana_log_level" {
  type        = string
  description = "The log level for the Grafana application"
  default     = "INFO"
}

variable "oauth_name" {
  type        = string
  description = "The name to use for OAuth (for identification)"
}

variable "oauth_domain" {
  type        = string
  description = "The domain for OAuth. Will be used to call authorize, token, and userinfo endpoints"
}

variable "oauth_client_id" {
  type        = string
  description = "The client ID for OAuth"
}

variable "oauth_client_secret" {
  type        = string
  description = "The client secret for OAuth"
}

variable "cloudflare_zone_id" {
  description = "Cloudflare zone ID"
  type        = string
}

variable "cloudflare_record_name" {
  description = "DNS record name, including subdomain, not including the domain"
  type        = string
}

variable "cloudflare_record_tags" {
  description = "Tags for cloudflare DNS record"
  type        = list(string)
}

variable "cloudflare_certificate_arn" {
  description = "Cloudflare certificate ARN"
  type        = string
}
