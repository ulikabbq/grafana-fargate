# Grafana Fargate Terraform Module

This is a terraform module for Grafana running on AWS fargate with an Aurora RDS MySQL backend.

## Information / Prerequisites
A Route53 hosted zone along with a certificate ARN (a wildcard one works) is required for HTTPS.

### Available Variables

All required variables are further described in `variables.tf`
