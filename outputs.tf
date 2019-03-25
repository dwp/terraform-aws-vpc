output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

output "vpc_cidr_block" {
  value = "${aws_vpc.vpc.cidr_block}"
}

output "main_route_table_id" {
  value = "${aws_vpc.vpc.vpc_main_route_table_id}"
}

output "interface_vpce_sg_id" {
  value = "${aws_security_group.vpc_endpoints.id}"
}

output "ssm_iam_role_name" {
  value = "${aws_iam_role.ssm.name}"
}

output "ssm_instance_profile_name" {
  value = "${aws_iam_instance_profile.ssm.name}"
}
