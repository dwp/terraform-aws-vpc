resource "aws_vpc_endpoint" "aws_interface_vpc_endpoints" {
  for_each = local.interface_endpoints_to_create

  service_name        = "com.amazonaws.${var.region}.${each.value}"
  vpc_id              = aws_vpc.vpc.id
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  subnet_ids          = var.interface_vpce_subnet_ids
  private_dns_enabled = true

  tags = merge(
    var.common_tags,
    { Name = var.vpc_name }
  )
}

resource "aws_vpc_endpoint" "aws_gateway_vpc_endpoints" {
  for_each = local.gateway_endpoints_to_create

  service_name      = "com.amazonaws.${var.region}.${each.value}"
  vpc_id            = aws_vpc.vpc.id
  vpc_endpoint_type = "Gateway"
  route_table_ids   = var.gateway_vpce_route_table_ids

  tags = merge(
    var.common_tags,
    { Name = var.vpc_name }
  )
}

resource "aws_vpc_endpoint" "custom_vpc_endpoints" {
  for_each = var.custom_vpce_services

  service_name        = each.key
  vpc_id              = aws_vpc.vpc.id
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.vpc_endpoints.id] #TODO
  subnet_ids          = var.interface_vpce_subnet_ids
  private_dns_enabled = true

  tags = merge(
    var.common_tags,
    { Name = var.vpc_name }
  )
}


resource "aws_security_group" "vpc_endpoints" {
  name        = "vpc-endpoints-${var.vpc_name}"
  description = "Allows instances to reach Interface VPC endpoints"
  vpc_id      = aws_vpc.vpc.id

  tags = merge(
    var.common_tags,
    { Name = var.vpc_name }
  )
}

resource "aws_security_group_rule" "vpce_source_https_ingress" {
  for_each = var.interface_vpce_source_security_group_ids

  description              = "Accept VPCE traffic"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 443
  to_port                  = 443
  source_security_group_id = each.value
  security_group_id        = aws_security_group.vpc_endpoints.id
}

resource "aws_security_group_rule" "source_vpce_https_egress" {
  for_each = var.interface_vpce_source_security_group_ids

  description              = "Allow outbound requests to VPC endpoints"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 443
  to_port                  = 443
  source_security_group_id = aws_security_group.vpc_endpoints.id
  security_group_id        = each.value
}
