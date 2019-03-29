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

# To understand how this works
# 1. list() converts the boolean flag into a list, so that...
# 2. concat() joins the 2 lists (the potentially empty list of the resource in
#    question, and the list from step 1)
# 3. element() returns the first element of that newly combined list; it'll
#    either be the resource's attribute, or an empty string
output "s3_prefix_list_id" {
  value = "${element(concat(aws_vpc_endpoint.s3.*.prefix_list_id, list("")), 0)}"
}

output "dynamodb_prefix_list_id" {
  value = "${element(concat(aws_vpc_endpoint.dynamodb.*.prefix_list_id, list("")), 0)}"
}

output "ssm_iam_role_name" {
  value = "${element(concat(aws_iam_role.ssm.*.name, list("")), 0)}"
}

output "ssm_instance_profile_name" {
  value = "${element(concat(aws_iam_instance_profile.ssm.*.name, list("")), 0)}"
}
