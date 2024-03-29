output "vpc" {
  value       = aws_vpc.vpc
  description = "VPC Details"
}

output "interface_vpce_sg_id" {
  value       = aws_security_group.vpc_endpoints.id
  description = "VPCE SG endpoint ID"
}

output "custom_vpce_sg_id" {
  value       = aws_security_group.custom_vpc_endpoints.id
  description = "Custom VPCE SG endpoint ID"
}

output "custom_vpce_dns_names" {
  value = {
    for key in var.custom_vpce_services[*].key :
    key => aws_vpc_endpoint.custom_vpc_endpoints[key].dns_entry[*].dns_name
  }
  description = "Custom VPCE DNS Names"
}

output "prefix_list_ids" {
  value = {
    for service in setintersection(local.gateway_services, var.aws_vpce_services) :
    service => aws_vpc_endpoint.aws_gateway_vpc_endpoints[service].prefix_list_id
  }
  description = "Prefix List ID's"
}

output "ecr_dkr_domain_name" {
  value       = "dkr.ecr.${var.region}.amazonaws.com"
  description = "ECR dkr domain name"
}
locals {
  s3_no_proxy                   = contains(var.aws_vpce_services, "s3") ? [".s3.${var.region}.amazonaws.com"] : []
  s3_path_no_proxy              = contains(var.aws_vpce_services, "s3") ? ["*.s3.${var.region}.amazonaws.com"] : []
  s3_path_non_regional_no_proxy = contains(var.aws_vpce_services, "s3") ? ["*.s3.amazonaws.com"] : []
  ecr_api_no_proxy              = contains(var.aws_vpce_services, "ecr.api") ? ["api.ecr.${var.region}.amazonaws.com"] : []
  ecr_dkr_no_proxy              = contains(var.aws_vpce_services, "ecr.dkr") ? [".dkr.ecr.${var.region}.amazonaws.com"] : []
  emr_no_proxy                  = contains(var.aws_vpce_services, "elasticmapreduce") ? ["${var.region}.elasticmapreduce.amazonaws.com"] : []
  sqs_no_proxy                  = contains(var.aws_vpce_services, "sqs") ? ["${var.region}.queue.amazonaws.com"] : []
}

output "no_proxy_list" {
  value       = concat(["169.254.169.254", "127.0.0.1", "localhost"], formatlist("%s.%s.amazonaws.com", var.aws_vpce_services, var.region), local.s3_no_proxy, local.ecr_api_no_proxy, local.ecr_dkr_no_proxy, local.emr_no_proxy, local.sqs_no_proxy, local.s3_path_no_proxy, local.s3_path_non_regional_no_proxy)
  description = "No_proxy List"
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
  value       = concat(aws_iam_role.ssm.*.name, tolist([""]))[0]
  description = "SSM IAM Role Name"
}

output "ssm_instance_profile_name" {
  value       = concat(aws_iam_instance_profile.ssm.*.name, tolist([""]))[0]
  description = "SSM IAM instance profile Name"
}
