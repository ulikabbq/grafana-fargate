variable "aws_region" {
  default     = "us-east-1"
  description = "The primary AWS region"
}

variable "account_id" {
  default = ""
}

variable "aws_account_ids" {
  type        = map(string)
  description = "A mapping of AWS account IDs that have a Grafana role that allows Grafana to access CloudWatch metrics"

  default = {}
}

variable "whitelist_ips" {
  type        = list(string)
  description = "List of whitelisted ip addresses that can access grafana"

  default = ["0.0.0.0/0"]
}

variable "dns_zone" {
  description = "the Route 53 ZoneId"
  default     = ""
}

variable "dns_name" {
  description = "The DNS name"
  default     = ""
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
  default     = "ulikabbq/grafana:0.1"
}

variable "nginx_image_url" {
  description = "the image url for the nginx sidecar image"
  default     = "ulikabbq/nginx_grafana:0.1"
}

variable "bastion_count" {
  description = "the number of bastion host"
  default     = "1"
}

variable "key" {
  description = "key pair for accessing the bastion"
  default     = ""
}

variable "bastion_whitelist_ips" {
  description = "ips to whitelist to access the bastion"
  default     = [""]
}

variable "bastion_subnet" {
  description = "the subnet id for the bastion"
  default     = ""
}

