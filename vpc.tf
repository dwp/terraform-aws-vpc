resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  instance_tenancy     = var.vpc_instance_tenancy
  enable_dns_hostnames = var.vpc_enable_dns_hostnames

  tags = merge(
    var.common_tags,
    map("Name", var.vpc_name)
  )
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_flow_log" "flow_log" {
  iam_role_arn    = aws_iam_role.vpc_flow_logs.arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_logs.arn
  traffic_type    = var.vpc_flow_log_traffic_type
  vpc_id          = aws_vpc.vpc.id
}

resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "/aws/vpc-flow-logs/${var.vpc_name}"
  retention_in_days = var.vpc_flow_log_retention_days

  tags = merge(
    var.common_tags,
    { Name = var.vpc_name }
  )
}

data "aws_iam_policy_document" "vpc_flow_logs_assume_role" {
  statement {
    sid    = "VpcFlowLogsAssumeRole"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "vpc_flow_logs" {
  statement {
    sid       = "VpcFlowLogs${replace(var.vpc_name, "-", "")}"
    effect    = "Allow"
    resources = [aws_cloudwatch_log_group.vpc_flow_logs.arn]

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]
  }
}

resource "aws_iam_role" "vpc_flow_logs" {
  name               = "vpc_flow_logs_${var.vpc_name}"
  assume_role_policy = data.aws_iam_policy_document.vpc_flow_logs_assume_role.json

  tags = merge(
    var.common_tags,
    map("Name", var.vpc_name)
  )
}

resource "aws_iam_role_policy" "vpc_flow_logs" {
  name   = "vpc_flow_logs_${var.vpc_name}"
  role   = aws_iam_role.vpc_flow_logs.id
  policy = data.aws_iam_policy_document.vpc_flow_logs.json
}
