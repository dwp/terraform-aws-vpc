variable "vpc_name" {
  description = "The name of the VPC."
}

variable "vpc_cidr_block" {
  description = "The CIDR block of the VPC."
}

variable "vpc_instance_tenancy" {
  default     = "default"
  description = "Tenancy of instances spun up within the VPC (`default`, `dedicated`).)"
}

variable "region" {
  description = "The region in which to deploy the VPC."
}

variable "interface_vpce_source_security_group_count" {
  description = "The number of security group IDs given in interface_vpce_source_security_group_ids (to workaround https://github.com/hashicorp/terraform/issues/12570)."
}

variable "interface_vpce_source_security_group_ids" {
  type        = list(string)
  description = "A list of security group IDs that will be allowed to reach the Interface VPCs. Note that when setting this you must also set `interface_vpce_source_security_group_count` (see above)."
}

variable "interface_vpce_subnet_ids" {
  type        = list(string)
  description = "A list of subnet IDs that all Interface VPC endpoints will be attached to"
}

variable "vpc_enable_dns_hostnames" {
  default     = true
  description = "A boolean flag to enable/disable DNS hostnames in the VPC. Defaults to true."
}

variable "vpc_flow_log_retention_days" {
  default     = 180
  description = "The number of days to retain VPC flow logs in CloudWatch for. Defaults to 180."
}

variable "vpc_flow_log_traffic_type" {
  default     = "ALL"
  description = "The type of traffic ('ACCEPT', 'REJECT', or 'ALL') to log. Defaults to 'ALL'."
}

variable "aws_vpce_services" {
  type        = set(string)
  description = "List of AWS Service names to create VPC Endpoints for. By default only the 'logs' service endpoint is provided"
  default     = ["logs"]
}

variable "custom_vpce_services" {
  type        = map(string)
  description = "Map of service names to ports for custom VPC Endpoint services"
  default     = {}
}

variable "gateway_vpce_route_table_ids" {
  default     = []
  description = "A list of one or more route table IDs for Gateway VPC Endpoint rules to be added to."
}

variable "common_tags" {
  default = {}
}
