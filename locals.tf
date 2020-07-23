locals {
  gateway_services = ["dynamodb", "s3"]

  interface_endpoints_to_create = [
    for service in var.aws_vpce_services :
    service if ! contains(local.gateway_services, service)
  ]

  gateway_endpoints_to_create = setintersection(var.aws_vpce_services, local.gateway_services)

  # Creates an exhaustive list of tuples of the form [<security_group_id>, <port>]
  # where each <security_group_id> is one of the externally provided Security Group IDs
  # and <port> is one of the custom vpce services ports
  sg_id_to_port_mapping = tolist(setproduct(var.interface_vpce_source_security_group_ids, var.custom_vpce_services[*].port))

  service_names_with_dns      = setunion(local.interface_endpoints_to_create, var.custom_vpce_services[*].key)
  endpoint_resources_with_dns = merge(aws_vpc_endpoint.custom_vpc_endpoints, aws_vpc_endpoint.aws_interface_vpc_endpoints)

  vpce_subnet_combinations = [
    # in pair, element zero is a VPCE ID and element one is a Subnet ID,
    # in all unique combinations.
    for pair in setproduct(aws_vpc_endpoint.aws_interface_vpc_endpoints.*.id, var.interface_vpce_subnet_ids) : {
      vpce_id   = pair[0]
      subnet_id = pair[1]
    }
  ]

}
