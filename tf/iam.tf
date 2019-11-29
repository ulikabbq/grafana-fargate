// task execution assume role policy document
data "aws_iam_policy_document" "grafana_ecs_task_execution_assume_role" {
  statement {
    sid    = "AllowECSTasksToAssumeRole"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

// task execution role policy document
data "aws_iam_policy_document" "grafana_ecs_task_execution_role" {
  statement {
    sid    = "AllowECSToWriteLogsToCloudWatchLogs"
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [aws_cloudwatch_log_group.grafana.arn]
  }
}

// task execution role
resource "aws_iam_role" "grafana_ecs_task_execution" {
  name               = "grafana-ecs-task-execution"
  assume_role_policy = data.aws_iam_policy_document.grafana_ecs_task_execution_assume_role.json
}

// task execution role policy
resource "aws_iam_role_policy" "grafana_ecs_task_execution" {
  name   = "grafana-ecs-task-execution"
  role   = aws_iam_role.grafana_ecs_task_execution.name
  policy = data.aws_iam_policy_document.grafana_ecs_task_execution_role.json
}

// task assume role policy document
data "aws_iam_policy_document" "grafana_ecs_task_assume_role" {
  statement {
    sid    = "AllowECSTasksToAssumeRole"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

// task role policy document
data "aws_iam_policy_document" "grafana_ecs_task_role" {
  statement {
    sid     = "AllowServiceToAccessSecretsFromSSM"
    effect  = "Allow"
    actions = ["ssm:GetParametersByPath"]

    resources = [
      "arn:aws:ssm:${var.aws_region}:${var.account_id}:parameter/grafana/*",
    ]
  }

  statement {
    sid       = "AllowAccessToKMSForDecryptingSSMParameters"
    effect    = "Allow"
    actions   = ["kms:Decrypt"]
    resources = ["arn:aws:kms:${var.aws_region}:${var.account_id}:alias/aws/ssm"]
  }

  statement {
    sid       = "AllowAccessToAssumeGrafanaRole"
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = formatlist("arn:aws:iam::%s:role/Grafana", values(var.aws_account_ids))
  }

  statement {
    sid    = "DenyEverythingElse"
    effect = "Deny"

    not_actions = [
      "kms:Decrypt",
      "ssm:GetParametersByPath",
      "sts:AssumeRole",
    ]

    resources = ["*"]
  }
}

// task role
resource "aws_iam_role" "grafana_ecs_task" {
  name               = "grafana-ecs-task"
  assume_role_policy = data.aws_iam_policy_document.grafana_ecs_task_assume_role.json
}

// task role policy
resource "aws_iam_role_policy" "grafana_ecs_task" {
  name   = "grafana-ecs-task"
  role   = aws_iam_role.grafana_ecs_task.name
  policy = data.aws_iam_policy_document.grafana_ecs_task_role.json
}

// grafana assume role 
resource "aws_iam_role" "grafana_assume" {
  name               = "Grafana"
  assume_role_policy = data.aws_iam_policy_document.grafana_role_assume_role_policy.json
}

resource "aws_iam_role_policy" "grafana_assume_role" {
  name   = "ReadOnlyAccessToCloudWatchAndEC2"
  role   = aws_iam_role.grafana_assume.name
  policy = data.aws_iam_policy_document.grafana_role.json
}

data "aws_iam_policy_document" "grafana_role_assume_role_policy" {
  statement {
    sid     = "AllowTrustedAccountsToAssumeTheRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = formatlist("arn:aws:iam::%s:root", values(var.aws_account_ids))
    }
  }
}

data "aws_iam_policy_document" "grafana_role" {
  statement {
    sid    = "AllowReadingMetricsFromCloudWatch"
    effect = "Allow"

    actions = [
      "cloudwatch:GetMetricStatistics",
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

