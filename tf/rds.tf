resource "aws_security_group" "rds" {
  name_prefix = "grafana-aurora56"
  description = "RDS Aurora access from internal security groups"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow 3306 from defined security groups"
    protocol    = "tcp"
    from_port   = 3306
    to_port     = 3306

    security_groups = [
      aws_security_group.grafana_ecs.id,
    ]
  }

  tags = {
    Name        = "grafana-aurora56"
    Description = "RDS Aurora access from internal security groups"
    ManagedBy   = "Terraform"
  }
}

resource "aws_db_subnet_group" "grafana" {
  name        = "grafana-aurora56"
  description = "Subnets to launch RDS database into"
  subnet_ids  = var.db_subnet_ids

  tags = {
    Name        = "grafana-aurora56-subnet-group"
    Description = "Subnets to use for RDS databases"
    ManagedBy   = "Terraform"
  }
}

resource "random_password" "db_password" {
  length  = 16
  special = false
}
variable "secretString" {
 default = {
  username = var.grafana_db_username
  password = random_password.db_password.result
 }
}

resource "aws_secretsmanager_secret" "db_secret_string" {
 name = "grafana_backend_db_creds"
}

resource "aws_secretsmanager_secret_version" "secret" {
 secret_id = aws_secretsmanager_secret.db_secret_string.id
 secret_string = jsonencode(var.secretString)
}

data "aws_secretsmanager_secret_version" "creds" {
  secret_id = aws_secretsmanager_secret.db_secret_string.id
}

resource "aws_rds_cluster" "grafana" {
  engine                 = "aurora"
  database_name          = "grafana"
  master_username        = var.grafana_db_username
  master_password        = data.aws_secretsmanager_secret_version.creds['password']
  storage_encrypted      = true
  db_subnet_group_name   = aws_db_subnet_group.grafana.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  skip_final_snapshot    = true

  tags = {
    Name        = "grafana"
    Description = "RDS Aurora cluster for the grafana environment"
    ManagedBy   = "Terraform"
  }

  lifecycle {
    create_before_destroy = true
    prevent_destroy       = false
  }
}

resource "aws_rds_cluster_instance" "grafana" {
  count = "1"

  cluster_identifier         = aws_rds_cluster.grafana.id
  identifier                 = "grafana-${count.index}"
  engine                     = "aurora"
  instance_class             = var.db_instance_type
  publicly_accessible        = false
  db_subnet_group_name       = aws_db_subnet_group.grafana.name
  auto_minor_version_upgrade = true

  tags = {
    Name        = "grafana-aurora-instance"
    Description = "RDS Aurora cluster for the grafana environment"
    ManagedBy   = "Terraform"
  }

  lifecycle {
    create_before_destroy = true
  }
}

