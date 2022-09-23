data "aws_iam_policy_document" "grafana_role" {
  statement {
    sid    = "AllowReadingMetricsFromCloudWatch"
    effect = "Allow"

    actions = [
      "cloudwatch:GetMetric*",
      "cloudwatch:ListMetrics",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "AllowReadingTagsFromEC2"
    effect = "Allow"

    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeTags",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role" "grafana" {
  name               = "Grafana"
  assume_role_policy = data.aws_iam_policy_document.grafana_role_policy.json
}

resource "aws_iam_role_policy" "grafana_role" {
  name   = "ReadOnlyAccessToCloudWatchAndEC2"
  role   = aws_iam_role.grafana.name
  policy = data.aws_iam_policy_document.grafana_role.json
}

data "aws_iam_policy_document" "grafana_role_policy" {
  statement {
    sid     = "AllowTrustedAccountsToAssumeTheRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.grafana_account_id}:root"]
    }
  }
}

variable "grafana_account_id" {
  default = ""
  type    = string
}

