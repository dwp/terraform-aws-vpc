locals {
  gateway_services = ["dynamodb", "s3"]

  # This essentially implements the 'setsubtract' function available in Terraform v.0.12.21 and later
  interface_endpoints_to_create = toset([
    for service in var.aws_vpce_services :
    service if ! contains(local.gateway_services, service)
  ])

  gateway_endpoints_to_create = setintersection(var.aws_vpce_services, local.gateway_services)

  # Creates an exhaustive list of tuples of the form [<security_group_id>, <port>]
  # where each <security_group_id> is one of the externally provided Security Group IDs
  # and <port> is one of the custom vpce services ports
  sg_id_to_port_mapping = tolist(setproduct(var.interface_vpce_source_security_group_ids, var.custom_vpce_services[*].port))

  service_names_with_dns      = setunion(local.interface_endpoints_to_create, var.custom_vpce_services[*].key)
  endpoint_resources_with_dns = merge(aws_vpc_endpoint.custom_vpc_endpoints, aws_vpc_endpoint.aws_interface_vpc_endpoints)

  if_vpces = [
    for key, endpoint in aws_vpc_endpoint.aws_interface_vpc_endpoints : {
      key = endpoint.service_name
      id  = endpoint.id
    }
  ]

  if_vpce_subnets = [
    for key, subnet in var.interface_vpce_subnet_ids : {
      key = key
      id  = subnet
    }
  ]

  if_vpce_subnet_assocs = [
    for pair in setproduct(local.if_vpces, local.if_vpce_subnets) : {
      service_name = pair[0].key
      endpoint_id  = pair[0].id
      subnet_id    = pair[1].id
    }
  ]
}
