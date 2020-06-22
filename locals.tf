locals {
  gateway_services = ["dynamodb", "s3"]

  # This essentially implements the 'setsubtract' function available in Terraform v.0.12.21 and later
  interface_endpoints_to_create = toset([
    for service in var.aws_vpce_services :
    service if ! contains(local.gateway_services, service)
  ])

  gateway_endpoints_to_create = setintersection(var.aws_vpce_services, local.gateway_services)

  all_aws_endpoints = merge(aws_vpc_endpoint.aws_interface_vpc_endpoints, aws_vpc_endpoint.aws_gateway_vpc_endpoints)
}
