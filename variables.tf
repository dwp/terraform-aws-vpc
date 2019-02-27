variable "vpc_name" {
  description = "(Required) The name of the VPC."
}

variable "vpc_cidr_block" {
  description = "(Required) The CIDR block of the VPC."
}

variable "vpc_instance_tenancy" {
  default     = "default"
  description = "(Optional) Tenancy of instances spun up within the VPC (`default`, `dedicated`. Defaults to `default`)"
}

variable "region" {
  description = "(Optional) The region in which to deploy the VPC."
}

variable "vpc_enable_dns_hostnames" {
  default     = true
  description = "(Optional) A boolean flag to enable/disable DNS hostnames in the VPC. Defaults to true."
}

variable "vpc_flow_log_retention_days" {
  default     = 180
  description = "(Optional) The number of days to retain VPC flow logs in CloudWatch for. Defaults to 180."
}

variable "vpc_flow_log_traffic_type" {
  default     = "ALL"
  description = "(Optional) The type of traffic ('ACCEPT', 'REJECT', or 'ALL') to log. Defaults to 'ALL'."
}

variable "s3_endpoint" {
  default     = true
  description = "(Optional) Place an S3 VPC endpoint in this VPC. Defaults to true. If set to true, you will also need to set `gateway_vpce_route_table_ids`"
}

variable "ssm_endpoint" {
  default     = true
  description = "(Optional) Place an SSM VPC endpoint in this VPC. Defaults to true. If set to true, you will also need to set `interface_vpce_security_group_ids` and `interface_vpce_subnet_ids`"
}

variable "ssmmessages_endpoint" {
  default     = true
  description = "(Optional) Place an SSM Messages VPC endpoint in this VPC. Defaults to true. If set to true, you will also need to set `interface_vpce_security_group_ids` and `interface_vpce_subnet_ids`"
}

variable "ec2_endpoint" {
  default     = true
  description = "(Optional) Place an EC2 VPC endpoint in this VPC. Defaults to true. If set to true, you will also need to set `interface_vpce_security_group_ids` and `interface_vpce_subnet_ids`"
}

variable "ec2messages_endpoint" {
  default     = true
  description = "(Optional) Place an EC2 Messages VPC endpoint in this VPC. Defaults to true. If set to true, you will also need to set `interface_vpce_security_group_ids` and `interface_vpce_subnet_ids`"
}

variable "logs_endpoint" {
  default     = true
  description = "(Optional) Place a CloudWatch Logs VPC endpoint in this VPC. Defaults to true. If set to true, you will also need to set `interface_vpce_security_group_ids` and `interface_vpce_subnet_ids`"
}

variable "sns_endpoint" {
  default     = false
  description = "(Optional) Place an SNS VPC endpoint in this VPC. Defaults to false. If set to true, you will also need to set `interface_vpce_security_group_ids` and `interface_vpce_subnet_ids`"
}

variable "gateway_vpce_route_table_ids" {
  default     = []
  description = "(Optional) A list of one or more route table IDs for Gateway VPC Endpoint rules to be added to."
}

variable "interface_vpce_source_security_group_count" {
  default     = 0
  description = "(Optional) The number of security group IDs given in interface_vpce_source_security_group_ids (to workaround https://github.com/hashicorp/terraform/issues/12570). Defaults to 0."
}

variable "interface_vpce_source_security_group_ids" {
  default     = []
  description = "(Optional) A list of security group IDs that will be allowed to reach the Interface VPCs"
}

variable "interface_vpce_subnet_ids" {
  default     = []
  description = "(Optional) A list of subnet IDs that all Interface VPC endpoints will be attached to"
}

variable "common_tags" {
  default = {}
}
