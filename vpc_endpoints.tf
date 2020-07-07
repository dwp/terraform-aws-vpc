resource "aws_vpc_endpoint" "aws_interface_vpc_endpoints" {
  for_each = local.interface_endpoints_to_create

  service_name        = "com.amazonaws.${var.region}.${each.value}"
  vpc_id              = aws_vpc.vpc.id
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = merge(
    var.common_tags,
    { Name = var.vpc_name }
  )
}

resource "aws_vpc_endpoint_subnet_association" "aws_vpce_subnet_assoc" {
  for_each = {
    for assoc in local.if_vpce_subnet_assocs : "${assoc.service_name}.${assoc.subnet_id}" => assoc
  }
  vpc_endpoint_id = each.value.endpoint_id
  subnet_id       = each.value.subnet_id
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
  for_each = {
    for service in var.custom_vpce_services :
    service["key"] => service["service_name"]
  }

  service_name        = each.value
  vpc_id              = aws_vpc.vpc.id
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.custom_vpc_endpoints.id]
  subnet_ids          = var.interface_vpce_subnet_ids
  private_dns_enabled = false

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

resource "aws_security_group" "custom_vpc_endpoints" {
  description = "Allows instances to reach Custom VPC endpoints"
  vpc_id      = aws_vpc.vpc.id
  tags        = var.common_tags
}

resource "aws_security_group_rule" "custom_vpce_source_ingress" {
  count = length(local.sg_id_to_port_mapping)

  description              = "Allow instance traffic to Custom VPCE"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = local.sg_id_to_port_mapping[count.index][1]
  to_port                  = local.sg_id_to_port_mapping[count.index][1]
  source_security_group_id = local.sg_id_to_port_mapping[count.index][0]
  security_group_id        = aws_security_group.custom_vpc_endpoints.id
}

resource "aws_security_group_rule" "source_custom_vpce_egress" {
  count = length(local.sg_id_to_port_mapping)

  description              = "Accept Custom VPCE traffic"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = local.sg_id_to_port_mapping[count.index][1]
  to_port                  = local.sg_id_to_port_mapping[count.index][1]
  source_security_group_id = aws_security_group.custom_vpc_endpoints.id
  security_group_id        = local.sg_id_to_port_mapping[count.index][0]
}
