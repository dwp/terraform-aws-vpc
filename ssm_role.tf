resource "aws_iam_role" "ssm" {
  count              = contains(var.aws_vpce_services, "ssm") ? 1 : 0
  name               = "ssm_${var.vpc_name}"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
  tags               = var.common_tags
}

resource "aws_iam_role_policy_attachment" "ec2_for_ssm_attachment" {
  count      = contains(var.aws_vpce_services, "ssm") ? 1 : 0
  role       = aws_iam_role.ssm[count.index].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_instance_profile" "ssm" {
  count = contains(var.aws_vpce_services, "ssm") ? 1 : 0
  name  = "ssm_${var.vpc_name}"
  role  = aws_iam_role.ssm[count.index].name
}
