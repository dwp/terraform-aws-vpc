resource "aws_iam_role" "ssm" {
  count              = "${var.ssm_endpoint ? 1 : 0}"
  name               = "ssm_${var.vpc_name}"
  assume_role_policy = "${data.aws_iam_policy_document.ec2_assume_role.json}"
}

resource "aws_iam_role_policy_attachment" "ec2_for_ssm_attachment" {
  count      = "${var.ssm_endpoint ? 1 : 0}"
  role       = "${aws_iam_role.ssm.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
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
  count = "${var.ssm_endpoint ? 1 : 0}"
  name  = "ssm_${var.vpc_name}"
  role  = "${aws_iam_role.ssm.name}"
}
