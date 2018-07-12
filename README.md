# Grafana Fargate Terraform Module

This is a terraform module for Grafana running on AWS fargate with an Aurora RDS MySQL backend.

Here is the blog post that covers this setup:  
https://medium.com/247sports-engineering/highly-available-grafana-running-on-aws-fargate-and-rds-aurora-2bbea9d41b50

## Information / Prerequisites

Even though this terraform module will setup all the infrastructure you need, there are a couple of manual steps. To setup the database it requires running a bastion host and executing 3 mysql commands and there are 2 ssm parameters that are expected to be in the account.  

The 2 secrets that should be stored in ssm BEFORE running the module are `/grafana/GF_DATABASE_PASSWORD` and `/grafana/GF_SECURITY_ADMIN_PASSWORD`

### Run an aws cli command to create the database password

aws ssm put-parameter --name "/grafana/GF_DATABASE_PASSWORD" --type "SecureString" --value "foo"

### Run an aws cli command to create the grafana password

aws ssm put-parameter --name "/grafana/GF_SECURITY_ADMIN_PASSWORD" --type "SecureString" --value "bar"

### Setup

Because this setup enforces HTTPS, it is required to provide a DNS name space, a Route53 zone id, and certificate arn. There are also 2 secret values that should be manually created. Run the commands below to set the database password and the admin password for grafana.

### Example

```HCL
module "grafana" {
  source = "git@github.com:ulikabbq/grafana-fargate?ref=v0.3//tf"

  account_id    = "883447927050"
  dns_zone      = "E37HSFATM75UF"
  dns_name      = "grafana.exampledomain.com"
  cert_arn      = "arn:aws:acm:us-east-1:883447927050:certificate/c037931f-c278-4cc4-a228-a2a7ea751dc5"
  vpc_id        = "vpc-04e9a561"
  subnets       = ["subnet-61swn044xb5p"]
  lb_subnets    = ["subnet-7p20dzd4d68o", "subnet-2drmc0b737ij"]
  db_subnet_ids = ["subnet-9i3qthun5kr8", "subnet-76sm7yb9ofja"]

  //bastion setup
  bastion_count         = "1"
  key                   = "bastion"
  bastion_whitelist_ips = ["0.0.0.0/0"]
  bastion_subnet        = "subnet-7p20dzd4d68o"

  aws_account_ids = {
    default = "883447927050"
  }
}

output "grafana_rds" {
  value = "${module.grafana.grafana_rds}"
}

output "grafana_bastion_ip" {
  value = "${module.grafana.grafana_bastion_ip}"
}

output "grafana_role" {
  value = "${module.grafana.grafana_role}"
}
```

### Available Variables

**aws_region:** the default region is `us-east-1`

**account_id:** (Required) the account to run the grafana service

**aws_account_ids** the other account ids you wish to monitor

**whitelist_ips:** the default is `0.0.0.0/0` so anyone would be able to reach the grafana instance. this is a list variable of ip addresses that can access grafana

**bastion_whitelist_ips** the default is `0.0.0.0/0` so anyone would be able to ssh to the bastion instance. this is a list variable of ip addresses that can access the bastion host

**dns_zone:** (Required) the Route53 zone id. this id is used to create the dns name

**dns_name:** (Required) the dns name for the grafana service. example: `grafana.example.com`

**cert_arn** (Required)

**vpc_id** (Required)

**subnets** (Required)

**lb_subnets** (Required)

**db_subnet_ids** (Required)

**db_instance_type** the default is `db.t2.small`

**image_url** the default is `ulikabbq/grafana:v0.1`

**nginx_image_url** the default is `ulikabbq/nginx_grafana:v0.1`

**bastion_count** the number of bastion host. the deafult is 1, but set to 0 when the Aurora setup is complete

**key** the key used to ssh into the bastion

**bastion_whitelist_ips** the list of allowed ips to ssh to the bastion

**bastion_subnet** the subnet for the bastion host

### Aurora Setup

Log into the bastion to access the Aurora database and run these commands:

    mysql> GRANT USAGE ON `grafana`.* to 'grafana'@'<grafana-instance-001-EXAMPLE.us-east-1.rds.amazonaws.com>' identified by '<the password stored in ssm>';

    mysql> GRANT ALL PRIVILEGES ON `grafana`.* to 'grafana'@'<grafana-instance-001-EXAMPLE.us-east-1.rds.amazonaws.com>' with grant option;

    mysql> flush privileges;

### Grafana Configuration

To Do: Add the grafana configuration to set the datasource in the base account.