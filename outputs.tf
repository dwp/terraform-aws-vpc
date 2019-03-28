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

output "s3_prefix_list_id" {
  value = "${var.s3_endpoint ? aws_vpc_endpoint.s3.0.prefix_list_id: ""}"
}

output "dynamodb_prefix_list_id" {
  value = "${var.dynamodb_endpoint ? aws_vpc_endpoint.dynamodb.0.prefix_list_id: ""}"
}

output "ssm_iam_role_name" {
  value = "${aws_iam_role.ssm.*.name}"
}

output "ssm_instance_profile_name" {
  value = "${aws_iam_instance_profile.ssm.*.name}"
}
