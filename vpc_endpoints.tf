resource "aws_vpc_endpoint" "s3" {
  count             = "${var.s3_endpoint ? 1: 0}"
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_id            = "${aws_vpc.vpc.id}"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = ["${var.gateway_vpce_route_table_ids}"]
}

resource "aws_vpc_endpoint" "ssm" {
  count               = "${var.ssm_endpoint ? 1 : 0}"
  service_name        = "com.amazonaws.${var.region}.ssm"
  vpc_id              = "${aws_vpc.vpc.id}"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = ["${aws_security_group.vpc_endpoints.id}"]
  subnet_ids          = ["${var.interface_vpce_subnet_ids}"]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ec2messages" {
  count               = "${var.ec2messages_endpoint ? 1 : 0}"
  service_name        = "com.amazonaws.${var.region}.ec2messages"
  vpc_id              = "${aws_vpc.vpc.id}"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = ["${aws_security_group.vpc_endpoints.id}"]
  subnet_ids          = ["${var.interface_vpce_subnet_ids}"]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ec2" {
  count               = "${var.ec2_endpoint ? 1 : 0}"
  service_name        = "com.amazonaws.${var.region}.ec2"
  vpc_id              = "${aws_vpc.vpc.id}"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = ["${aws_security_group.vpc_endpoints.id}"]
  subnet_ids          = ["${var.interface_vpce_subnet_ids}"]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ssmmessages" {
  count               = "${var.ssmmessages_endpoint ? 1 : 0}"
  service_name        = "com.amazonaws.${var.region}.ssmmessages"
  vpc_id              = "${aws_vpc.vpc.id}"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = ["${aws_security_group.vpc_endpoints.id}"]
  subnet_ids          = ["${var.interface_vpce_subnet_ids}"]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "logs" {
  count               = "${var.logs_endpoint ? 1 : 0}"
  service_name        = "com.amazonaws.${var.region}.logs"
  vpc_id              = "${aws_vpc.vpc.id}"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = ["${aws_security_group.vpc_endpoints.id}"]
  subnet_ids          = ["${var.interface_vpce_subnet_ids}"]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "sns" {
  count               = "${var.sns_endpoint ? 1 : 0}"
  service_name        = "com.amazonaws.${var.region}.sns"
  vpc_id              = "${aws_vpc.vpc.id}"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = ["${aws_security_group.vpc_endpoints.id}"]
  subnet_ids          = ["${var.interface_vpce_subnet_ids}"]
  private_dns_enabled = true
}

resource "aws_security_group" "vpc_endpoints" {
  name        = "vpc-endpoints-${var.vpc_name}"
  description = "Allows instances to reach Interface VPC endpoints"
  vpc_id      = "${aws_vpc.vpc.id}"
  tags        = "${var.common_tags}"
}

resource "aws_security_group_rule" "vpce_source_https_ingress" {
  count                    = "${var.interface_vpce_source_security_group_count}"
  description              = "Accept VPCE traffic"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 443
  to_port                  = 443
  source_security_group_id = "${element(var.interface_vpce_source_security_group_ids, count.index)}"
  security_group_id        = "${aws_security_group.vpc_endpoints.id}"
}

resource "aws_security_group_rule" "source_vpce_https_egress" {
  count                    = "${var.interface_vpce_source_security_group_count}"
  description              = "Allow outbound requests to VPC endpoints"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 443
  to_port                  = 443
  source_security_group_id = "${element(var.interface_vpce_source_security_group_ids, count.index)}"
  security_group_id        = "${aws_security_group.vpc_endpoints.id}"
}
