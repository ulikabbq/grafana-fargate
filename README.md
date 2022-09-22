# Grafana Fargate Terraform Module

This is a terraform module for Grafana running on AWS fargate with an Aurora RDS MySQL backend.

## Information / Prerequisites

Prior to deploying the terraform module, there must be a Secret in AWS Secret Manager with the name `grafana-backend-db-creds`.
This secret should contain a `password` key pair keyed to the password to be used for the Grafana backend database.

Further a Route53 hosted zone along with a certificate ARN (a wildcard one works) is required for HTTPS.

### Available Variables

All required variables are described in `variables.tf`
