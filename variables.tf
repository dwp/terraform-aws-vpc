variable "vpc_name" {
  type        = string
  description = "The name of the VPC."
}

variable "vpc_cidr_block" {
  type        = string
  description = "The CIDR block of the VPC."
}

variable "vpc_instance_tenancy" {
  type        = string
  default     = "default"
  description = "Tenancy of instances spun up within the VPC (`default`, `dedicated`).)"
}

variable "region" {
  type        = string
  description = "The region in which to deploy the VPC."
}

variable "interface_vpce_source_security_group_ids" {
  type        = list(string)
  description = "A list of security group IDs that will be allowed to reach the Interface VPCs."
  default     = []
}

variable "interface_vpce_subnet_ids" {
  type        = list(string)
  description = "A list of subnet IDs that all Interface VPC endpoints will be attached to"
  default     = []
}

variable "vpc_enable_dns_hostnames" {
  type        = bool
  default     = true
  description = "A boolean flag to enable/disable DNS hostnames in the VPC. Defaults to true."
}

variable "vpc_flow_log_retention_days" {
  type        = string
  default     = 180
  description = "The number of days to retain VPC flow logs in CloudWatch for. Defaults to 180."
}

variable "vpc_flow_log_traffic_type" {
  type        = string
  default     = "ALL"
  description = "The type of traffic ('ACCEPT', 'REJECT', or 'ALL') to log. Defaults to 'ALL'."
}

variable "aws_vpce_services" {
  type        = set(string)
  description = "Set of AWS Service names to create VPC Endpoints for. By default only the 'logs' service endpoint is provided"
  default     = ["logs"]
}

variable "custom_vpce_services" {
  type = set(object({
    key          = string
    service_name = string
    port         = number
  }))

  description = "Set of objects mapping service names to ports for custom VPC Endpoint services. The key is used to provide a friendly name when accessing outputs."
  default     = []
}

variable "gateway_vpce_route_table_ids" {
  type        = list(string)
  default     = []
  description = "A list of one or more route table IDs for Gateway VPC Endpoint rules to be added to."
}

variable "common_tags" {
  type        = map(string)
  description = "Common Tags"
  default     = {}
}

variable "hcs_tags" {
  type        = map(string)
  description = "Common Tags"
  default     = {}
}

variable "test_account" {
  type        = string
  description = "Test AWS Account number"

}
