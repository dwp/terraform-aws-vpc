output "vpc" {
  value = aws_vpc.vpc
}

output "interface_vpce_sg_id" {
  value = aws_security_group.vpc_endpoints.id
}

output "custom_vpce_sg_id" {
  value = aws_security_group.custom_vpc_endpoints.id
}

output "custom_vpce_dns_names" {
  value = {
    for key in var.custom_vpce_services[*].key :
    key => aws_vpc_endpoint.custom_vpc_endpoints[key].dns_entry[*].dns_name
  }
}

output "prefix_list_ids" {
  value = {
    for service in setintersection(local.gateway_services, var.aws_vpce_services) :
    service => aws_vpc_endpoint.aws_gateway_vpc_endpoints[service].prefix_list_id
  }
}

output "ecr_dkr_domain_name" {
  value = "dkr.ecr.${var.region}.amazonaws.com"
}

output "no_proxy_list" {
  value = flatten(values({
    for service in local.service_names_with_dns :
    service => local.endpoint_resources_with_dns[service].dns_entry[*].dns_name
  }))
}


# Note that all of the outputs below are conditional, based on their respective
# endpoints having been requested. Naively, you'd think the following would work:
# value = "${var.s3_endpoint ? aws_vpc_endpoint.s3.0.prefix_list_id : ""}"
# but you end up running into https://github.com/hashicorp/hil/issues/50 so we
# use the workaround from that issue to achieve the same goal

# To understand how this works
# 1. list() converts the boolean flag into a list, so that...
# 2. concat() joins the 2 lists (the potentially empty list of the resource in
#    question, and the list from step 1)
# 3. element() returns the first element of that newly combined list; it'll
#    either be the resource's attribute, or an empty string


output "ssm_iam_role_name" {
  value = concat(aws_iam_role.ssm.*.name, list(""))[0]
}

output "ssm_instance_profile_name" {
  value = concat(aws_iam_instance_profile.ssm.*.name, list(""))[0]
}
