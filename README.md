# Grafana Fargate Terraform Module

This is a terraform module for Grafana running on AWS fargate with an Aurora RDS MySQL backend.  

Here is the blog post that covers this setup:  
https://medium.com/247sports-engineering

## Information

Even though this terraform module will setup all the infrastructure you need, there are a couple of manual steps. 
- the terraform module will output the ecr repos that are created and the nginx and  





## Prerequisites

Because this setup enforces HTTPS, it is required to provide a DNS name space, a Route53 zone id, and certificate arn.

Run an aws cli command to create the database password
aws ssm put-parameter --name "/grafana/rds/master_password" --type "SecureString" --value "foo"

### Setup

module "grafana" {
  source = "git@github.com:ulikabbq/grafana-fargate?ref=v0.1//tf"

  account_id    = ""
  dns_zone      = ""
  dns_name      = ""
  cert_arn      = ""
  vpc_id        = ""
  subnets       = ""
  lb_subnets    = ""
  db_subnet_ids = ""
}

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


### ECS Setup
Terraform creates 2 ecr repos. Run the `image_upload.sh` to put the containers in the ECR repos
* **grafana:** this image has a base of `grafana/grafana` and it is configured to install Chamber to retrive the enviornment variables from SSM. 

* **grafana-nginx:** this image has a base of `nginx:1.13.9-alpine` and it is configured to be a passthrough to http://localhost:3000 where grafana runs. This container runs on port 80 and is the destination for the grafana target group. 

### Aurora Setup
Log into the Aurora database and run these commands: 

    mysql> create database grafana;
    
    mysql> GRANT USAGE ON `grafana`.* to 'grafana'@'<grafana-instance-001-EXAMPLE.us-east-1.rds.amazonaws.com>' identified by '<a password>';
   
    mysql> GRANT ALL PRIVILEGES ON `grafana`.* to 'grafana'@'<grafana-instance-001-EXAMPLE.us-east-1.rds.amazonaws.com>' with grant option;
    
    mysql> flush privileges;

### Grafana Configuration 