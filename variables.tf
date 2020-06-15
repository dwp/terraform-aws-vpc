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

variable "dynamodb_endpoint" {
  default     = false
  description = "Place a DynamoDB VPC endpoint in this VPC. If set to true, you will also need to set `gateway_vpce_route_table_ids`"
}

variable "ec2_endpoint" {
  default     = false
  description = "Place an EC2 VPC endpoint in this VPC. If set to true, you will also need to set `interface_vpce_source_security_group_ids` and `interface_vpce_subnet_ids`"
}

variable "ec2messages_endpoint" {
  default     = false
  description = "Place an EC2 Messages VPC endpoint in this VPC. If set to true, you will also need to set `interface_vpce_source_security_group_ids` and `interface_vpce_subnet_ids`"
}

variable "ecrapi_endpoint" {
  default     = false
  description = "Place an ecr.api endpoint in this VPC. If set to true, you will also need to set `interface_vpce_source_security_group_ids` and `interface_vpce_subnet_ids`"
}

variable "ecrdkr_endpoint" {
  default     = false
  description = "Place an ecr.dkr endpoint in this VPC. If set to true, you will also need to set `interface_vpce_source_security_group_ids` and `interface_vpce_subnet_ids`"
}

variable "ecs_endpoint" {
  default     = false
  description = "Place an ecs endpoint in this VPC. If set to true, you will also need to set `interface_vpce_source_security_group_ids` and `interface_vpce_subnet_ids`"
}

variable "ecs-agent_endpoint" {
  default     = false
  description = "Place an ecs-agent endpoint in this VPC. If set to true, you will also need to set `interface_vpce_source_security_group_ids` and `interface_vpce_subnet_ids`"
}

variable "ecs-telemetry_endpoint" {
  default     = false
  description = "Place an ecs-telemetry endpoint in this VPC. If set to true, you will also need to set `interface_vpce_source_security_group_ids` and `interface_vpce_subnet_ids`"
}

variable "kms_endpoint" {
  default     = false
  description = "Place a KMS endpoint in this VPC. If set to true, you will also need to set `interface_vpce_source_security_group_ids` and `interface_vpce_subnet_ids`"
}

variable "logs_endpoint" {
  default     = true
  description = "Place a CloudWatch Logs VPC endpoint in this VPC. If set to true, you will also need to set `interface_vpce_source_security_group_ids` and `interface_vpce_subnet_ids`"
}

variable "monitoring_endpoint" {
  default     = false
  description = "Place a CloudWatch Monitoring VPC endpoint in this VPC. If set to true, you will also need to set `interface_vpce_source_security_group_ids` and `interface_vpce_subnet_ids`"
}

variable "s3_endpoint" {
  default     = false
  description = "Place an S3 VPC endpoint in this VPC. If set to true, you will also need to set `gateway_vpce_route_table_ids`"
}

variable "sns_endpoint" {
  default     = false
  description = "Place an SNS VPC endpoint in this VPC. If set to true, you will also need to set `interface_vpce_source_security_group_ids` and `interface_vpce_subnet_ids`"
}

variable "sqs_endpoint" {
  default     = false
  description = "Place an SQS VPC endpoint in this VPC. If set to true, you will also need to set `interface_vpce_source_security_group_ids` and `interface_vpce_subnet_ids`"
}

variable "ssm_endpoint" {
  default     = false
  description = "Place an SSM VPC endpoint in this VPC. If set to true, you will also need to set `interface_vpce_source_security_group_ids` and `interface_vpce_subnet_ids`"
}

variable "ssmmessages_endpoint" {
  default     = false
  description = "Place an SSM Messages VPC endpoint in this VPC. If set to true, you will also need to set `interface_vpce_source_security_group_ids` and `interface_vpce_subnet_ids`"
}

variable "glue_endpoint" {
  default     = false
  description = "Place an Glue VPC endpoint in this VPC. If set to true, you will also need to set `interface_vpce_source_security_group_ids` and `interface_vpce_subnet_ids`"
}

variable "secretsmanager_endpoint" {
  default     = false
  description = "Place a Secrets Manager VPC endpoint in this VPC. If set to true, you will also need to set `interface_vpce_source_security_group_ids` and `interface_vpce_subnet_ids`"
}

variable "emr_endpoint" {
  default     = false
  description = "Place an ElasticMapReduce VPC endpoint in this VPC. If set to true, you will also need to set `interface_vpce_source_security_group_ids` and `interface_vpce_subnet_ids`"
}

variable "ec2autoscaling_endpoint" {
  default     = false
  description = "Place an EC2 Auto Scaling VPC endpoint in this VPC. If set to true, you will also need to set `interface_vpce_source_security_group_ids` and `interface_vpce_subnet_ids`"
}

variable "elasticloadbalancing_endpoint" {
  default     = false
  description = "Place an elasticloadbalancing endpoint in this VPC. If set to true, you will also need to set `interface_vpce_source_security_group_ids` and `interface_vpce_subnet_ids`"
}

variable "events_endpoint" {
  default     = false
  description = "Place an events endpoint in this VPC. If set to true, you will also need to set `interface_vpce_source_security_group_ids` and `interface_vpce_subnet_ids`"
}

variable "application_autoscaling_endpoint" {
  default     = false
  description = "Place an application_autoscaling endpoint in this VPC. If set to true, you will also need to set `interface_vpce_source_security_group_ids` and `interface_vpce_subnet_ids`"
}

variable "kinesis_firehose_endpoint" {
  default     = false
  description = "Place a firehouse endpoint in this VPC. If set to true, you will also need to set `interface_vpce_source_security_group_ids` and `interface_vpce_subnet_ids`"
}

variable "internet_proxy_endpoint_service_name" {
  description = "If specified, the module creates a VPC endpoint for the given internet proxy service name.  If set you will also need to set `interface_vpce_source_security_group_ids` and `interface_vpce_subnet_ids`"
  default     = null
}

variable "gateway_vpce_route_table_ids" {
  default     = []
  description = "A list of one or more route table IDs for Gateway VPC Endpoint rules to be added to."
}

variable "common_tags" {
  default = {}
}
