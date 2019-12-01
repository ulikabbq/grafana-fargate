# UPDATE 12.01.2019 
It has been a while since I last visited this project and I felt like it needed some updating. The good news is that now it is 
even easier to get this module up and running. 

## Updates 
* Upgraded to Terraform 0.12
* Added GitHub Actions to publish and deploy the fargate container 
* Grafana version 6.5.1 
* Removed the bastion host (no longer need to run the mysql commands)
* Removed nginx (was handling https redirects that are now in the lb listener)

# Grafana Fargate Terraform Module

This is a terraform module for Grafana running on AWS fargate with an Aurora RDS MySQL backend.

Here is the blog post that covers this setup:  
https://medium.com/247sports-engineering/highly-available-grafana-running-on-aws-fargate-and-rds-aurora-2bbea9d41b50

## Information / Prerequisites

Even though this terraform module will setup all the infrastructure you need, there are a couple of manual steps. There are 2 ssm parameters that are expected to be in the account.  

The 2 secrets that should be stored in ssm BEFORE running the module are `/grafana/GF_DATABASE_PASSWORD` and `/grafana/GF_SECURITY_ADMIN_PASSWORD`

### Run an aws cli command to create the database password

aws ssm put-parameter --name "/grafana/GF_DATABASE_PASSWORD" --type "SecureString" --value "foo"

### Run an aws cli command to create the grafana password

aws ssm put-parameter --name "/grafana/GF_SECURITY_ADMIN_PASSWORD" --type "SecureString" --value "bar"

### Setup

Because this setup enforces HTTPS, it is required to provide a DNS name space, a Route53 zone id, and certificate arn. There are also 2 secret values that should be manually created. Run the commands above to set the database password and the admin password for grafana.

### Example

```HCL
module "grafana" {
  source = "git@github.com:ulikabbq/grafana-fargate?ref=v1.0//tf"

  dns_zone        = "ZZ7C1JZLM75QT"
  region          = "us-east-1"
  vpc_id          = "vpc-04e9a561"
  lb_subnets      = ["subnet-6ef25245", "subnet-32089345"]
  subnets         = ["subnet-28fd4671", "subnet-8ad27ca4"]
  db_subnet_ids   = ["subnet-6ef25245", "subnet-32089345"]
  cert_arn        = "arn:aws:acm:us-east-1:433223883348:certificate/9891d84e-8a28-4531-afdb-78a2719b1a63"
  dns_name        = "grafana.ulikabbq.com"
  account_id      = "433223883348"
  aws_account_ids = { main = "433223883348" }
}

```

### Available Variables

**aws_region:** the default region is `us-east-1`

**account_id:** (Required) the account to run the grafana service

**aws_account_ids** the other account ids you wish to monitor

**whitelist_ips:** the default is `0.0.0.0/0` so anyone would be able to reach the grafana instance. this is a list variable of ip addresses that can access grafana

**dns_zone:** (Required) the Route53 zone id. this id is used to create the dns name

**dns_name:** (Required) the dns name for the grafana service. example: `grafana.example.com`

**cert_arn** (Required)

**vpc_id** (Required)

**subnets** (Required)

**lb_subnets** (Required)

**db_subnet_ids** (Required)

**db_instance_type** the default is `db.t2.small`

**image_url** the default is `ulikabbq/grafana:v0.1`


### Grafana Configuration

Grafana is configured with ssm. To add grafana configurations, add ssm resources with a prefix of `/grafana/` and when the container loads, it will bring in the associated configuration. See grafana docs https://grafana.com/docs/installation/configuration/

```HCL
resource "aws_ssm_parameter" "GF_INSTALL_PLUGINS" {
  name  = "/grafana/GF_INSTALL_PLUGINS"
  type  = "String"
  value = "grafana-worldmap-panel,grafana-clock-panel,jdbranham-diagram-panel,natel-plotly-panel"
}
```

### GitHub Actions 
The GitHub Action in this repo will push the Dockerfile to ecr and update the grafana service. To utilize this action, change the account id in the task.json for the `executionRoleArn` and `taskRoleArn`. You will also need to add a `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` to GitHub secrets. 

### IAM Role for other monitored accounts 
For the accounts you want to monitor with Grafana, you will need a Grafana role in that account that the main grafana role can assume. To add this role run this module in the account. 

```HCL
module "iam" {
  source = "git@github.com:ulikabbq/grafana-fargate?ref=v1.0//tf/iam_role/"

  grafana_account_id = "433223883348"
}
```