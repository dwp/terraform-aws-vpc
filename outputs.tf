output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

output "vpc_cidr_block" {
  value = "${aws_vpc.vpc.cidr_block}"
}

output "main_route_table_id" {
  value = "${aws_vpc.vpc.main_route_table_id}"
}

output "interface_vpce_sg_id" {
  value = "${aws_security_group.vpc_endpoints.id}"
}

# Note that all of the outputs below are conditional, based on their respective
# endpoints having been requested. Naively, you'd think the following would work:
# value = "${var.s3_endpoint ? aws_vpc_endpoint.s3.0.prefix_list_id : ""}"
# but you end up running into https://github.com/hashicorp/hil/issues/50 so we
# use the workaround from that issue to achieve the same goal

output "s3_prefix_list_id" {
  value = "${element(compact(concat(list(var.s3_endpoint), aws_vpc_endpoint.s3.*.prefix_list_id)), 0)}"
}

output "dynamodb_prefix_list_id" {
  value = "${element(compact(concat(list(var.dynamodb_endpoint), aws_vpc_endpoint.dynamodb.*.prefix_list_id)), 0)}"
}

output "ssm_iam_role_name" {
  value = "${element(compact(concat(list(var.ssm_endpoint), aws_iam_role.ssm.*.name)), 0)}"
}

output "ssm_instance_profile_name" {
  value = "${element(compact(concat(list(var.ssm_endpoint), aws_iam_instance_profile.ssm.*.name)), 0)}"
}
