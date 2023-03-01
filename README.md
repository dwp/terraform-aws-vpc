# terraform-aws-vpc
A Terraform module to create an AWS VPC with consistent features

## Usage

### Migration: v2.x -> v3.x
***Warning:*** Migrating from v2.x to v3.x will cause all VPC Endpoints to be destroyed
and recreated, which may cause downtime.

#### Breaking changes:
 * VPC Endpoint services are now passed as a list, see [examples section](#adding-endpoints---v3x)
 * Prefix list outputs are now grouped under a single output value and therefore
 accessed differently: `prefix_list_ids.<service_name>`
 (e.g.: `module.vpc.prefix_list_ids.dynamodb`)
 * Variable `interface_vpce_source_security_group_count` no longer needed

#### New features:
 * The module now exposes the `no_proxy_list` output, which is a list of all the
 VPC endpoint DNS names.
   * This is useful in environments which use a proxy for internet egress to let
   applications know not to use the proxy when connecting to AWS services which
   have a VPC endpoint created.
   * This list can be joined with `,` for use in `NO_PROXY` env vars or with `|`
   for use in the JVM `http.nonProxyHosts` flag
 * The module can now deploy VPC Endpoints for custom services, see
 [examples section](#adding-endpoints-for-custom-services---v3x)

### Default Configuration
In its simplest form, this module will create a VPC with VPC Flow Logs enabled.
As this results in a CloudWatch Logs VPC endpoint being created, you will need
to provide at least one subnet for the endpoint to be attached to. You will also
need to provide a list of security group IDs from which traffic destined to the
VPC endpoint will originate:

```
module "vpc" {
  source                                     = "dwp/vpc/aws"
  vpc_name                                   = "main"
  region                                     = "eu-west-2"
  vpc_cidr_block                             = "192.168.0.0/24"
  interface_vpce_source_security_group_ids   = ["${aws_security_group.source.id}"]
  interface_vpce_subnet_ids                  = ["${aws_subnet.main.id}"]
}
```

### Examples

#### Adding Endpoints - v3.x+

Version 3 of this module changes the way VPC endpoints are passed to the module
and created. The module now takes a list of AWS Service Names, and creates the
correct endpoint for each of them.

The names of the services are the ones found in the
[AWS Service Endpoints and Quotas documentation](https://docs.aws.amazon.com/general/latest/gr/aws-service-information.html),
not including the full DNS name, as per the following example.

```hcl-terraform
module "vpc" {
  source                                     = "dwp/vpc/aws"
  vpc_name                                   = "main"
  region                                     = "eu-west-2"
  vpc_cidr_block                             = "192.168.0.0/24"
  interface_vpce_source_security_group_ids   = ["${aws_security_group.source.id}"]
  interface_vpce_subnet_ids                  = ["${aws_subnet.main.id}"]

  aws_vpce_services = [
    "logs",
    "s3",
    "dynamodb",
    "ecr.dkr",
    "ec2",
    "ec2messages",
    "kms",
    "monitoring"
  ]
}
```

#### Adding Endpoints for custom services - v3.x+

After version 3 this module can deploy VPC Endpoints for custom services, and creates security
group rules to allow traffic to/from the custom service endpoints.

```hcl-terraform
module "vpc" {
  source                                     = "dwp/vpc/aws"
  vpc_name                                   = "main"
  region                                     = "eu-west-2"
  vpc_cidr_block                             = "192.168.0.0/24"
  interface_vpce_source_security_group_ids   = ["${aws_security_group.source.id}"]
  interface_vpce_subnet_ids                  = ["${aws_subnet.main.id}"]

  custom_vpce_services = [
    {
      key          = "my-service"
      service_name = "com.amazonaws.vpce.eu-west-2.vpce-svc-abcd1234"
      port         = 3128
    }
  ]
}
```
The `key` is used to provide a friendly name when accessing the DNS name output:

```hcl-terraform
resource "aws_resource" "r" {
  service_dns_name =  module.vpc.custom_vpce_dns_names["my-service"][0]
}
```

#### Adding Endpoints - v2.x

The example below shows how to create a VPC with SNS and SQS VPC endpoints:

```
module "vpc" {
  source                                     = "dwp/vpc/aws"
  vpc_name                                   = "main"
  region                                     = "eu-west-2"
  vpc_cidr_block                             = "192.168.0.0/24"
  interface_vpce_source_security_group_count = 1
  interface_vpce_source_security_group_ids   = ["${aws_security_group.source.id}"]
  interface_vpce_subnet_ids                  = ["${aws_subnet.main.id}"]
  sns_endpoint                               = true
  sqs_endpoint                               = true
}
```

#### Gateway Endpoint Configuration

S3 and DynamoDB VPC endpoints are Gateway endpoints, so require slightly
different configuration.  An example for S3 is provided below. For brevity, it
simply uses the VPC's default main route table, but you can pass any valid route
table ID to the module to ensure correct traffic flows:

```
module "vpc" {
  source                                     = "dwp/vpc/aws"
  vpc_name                                   = "ucfs-stub"
  region                                     = "eu-west-2"
  vpc_cidr_block                             = "10.0.0.0/24"
  s3_endpoint                                = true
  interface_vpce_source_security_group_count = 1
  interface_vpce_source_security_group_ids   = ["${aws_security_group.source.id}"]
  interface_vpce_subnet_ids                  = ["${aws_subnet.main.id}"]
  gateway_vpce_route_table_ids               = ["${module.vpc.main_route_table_id}"]
}
```

### Endpoint Use Cases

There are various use cases that can require a specific combination of VPC
endpoints to be enabled. Some of these that we have encountered are listed
below for ease of reference.  Links to AWS' documentation are provided for
further information

#### Systems Manager Session Manager

* ec2
* ec2messages
* ssm
* ssmmessages
* [SSM docs](https://docs.aws.amazon.com/systems-manager/latest/userguide/sysman-setting-up-vpc.html)

#### EMR (basic)

* emr
* s3
* [EMR docs](https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-clusters-in-a-vpc.html)

#### EMR with EMRFS

* emr
* s3
* dynamodb
* [EMR docs](https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-clusters-in-a-vpc.html)

#### EMR with EMRFS and Glue

* emr
* s3
* dynamodb
* glue
* [EMR docs](https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-clusters-in-a-vpc.html)

#### EMR with Debugging

* emr
* s3
* dynamodb
* sqs
* [EMR docs](https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-clusters-in-a-vpc.html)

#### ECS (EC2 Launch Type)

* ecs
* ecs-agent
* ecs-telemetry
* ecr.api (if using private images from ECR)
* ecr.dkr (if using private images from ECR)
* s3 (if using private images from ECR)
* [ECS docs](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/vpc-endpoints.html)
* [ECR docs](https://docs.aws.amazon.com/AmazonECR/latest/userguide/vpc-endpoints.html)

#### ECS (Fargate Launch Type)

* ecr.dkr (if using private images from ECR)
* s3 (if using private images from ECR)
* [ECS docs](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/vpc-endpoints.html)
* [ECR docs](https://docs.aws.amazon.com/AmazonECR/latest/userguide/vpc-endpoints.html)

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.vpc_flow_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_default_security_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) | resource |
| [aws_flow_log.flow_log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/flow_log) | resource |
| [aws_iam_instance_profile.ssm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.ssm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.vpc_flow_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.vpc_flow_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.ec2_for_ssm_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_security_group.custom_vpc_endpoints](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.vpc_endpoints](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.custom_vpce_source_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.source_custom_vpce_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.source_vpce_https_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.vpce_source_https_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_vpc.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_vpc_endpoint.aws_gateway_vpc_endpoints](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.aws_interface_vpc_endpoints](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.custom_vpc_endpoints](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_iam_policy_document.ec2_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.vpc_flow_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.vpc_flow_logs_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_vpce_services"></a> [aws\_vpce\_services](#input\_aws\_vpce\_services) | Set of AWS Service names to create VPC Endpoints for. By default only the 'logs' service endpoint is provided | `set(string)` | <pre>[<br>  "logs"<br>]</pre> | no |
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | Common Tags | `map(string)` | `{}` | no |
| <a name="input_custom_vpce_services"></a> [custom\_vpce\_services](#input\_custom\_vpce\_services) | Set of objects mapping service names to ports for custom VPC Endpoint services. The key is used to provide a friendly name when accessing outputs. | <pre>set(object({<br>    key          = string<br>    service_name = string<br>    port         = number<br>  }))</pre> | `[]` | no |
| <a name="input_gateway_vpce_route_table_ids"></a> [gateway\_vpce\_route\_table\_ids](#input\_gateway\_vpce\_route\_table\_ids) | A list of one or more route table IDs for Gateway VPC Endpoint rules to be added to. | `list(string)` | `[]` | no |
| <a name="input_hcs_tags"></a> [hcs\_tags](#input\_hcs\_tags) | Common Tags | `map(string)` | `{}` | no |
| <a name="input_interface_vpce_source_security_group_ids"></a> [interface\_vpce\_source\_security\_group\_ids](#input\_interface\_vpce\_source\_security\_group\_ids) | A list of security group IDs that will be allowed to reach the Interface VPCs. | `list(string)` | `[]` | no |
| <a name="input_interface_vpce_subnet_ids"></a> [interface\_vpce\_subnet\_ids](#input\_interface\_vpce\_subnet\_ids) | A list of subnet IDs that all Interface VPC endpoints will be attached to | `list(string)` | `[]` | no |
| <a name="input_region"></a> [region](#input\_region) | The region in which to deploy the VPC. | `string` | n/a | yes |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | The CIDR block of the VPC. | `string` | n/a | yes |
| <a name="input_vpc_enable_dns_hostnames"></a> [vpc\_enable\_dns\_hostnames](#input\_vpc\_enable\_dns\_hostnames) | A boolean flag to enable/disable DNS hostnames in the VPC. Defaults to true. | `bool` | `true` | no |
| <a name="input_vpc_flow_log_retention_days"></a> [vpc\_flow\_log\_retention\_days](#input\_vpc\_flow\_log\_retention\_days) | The number of days to retain VPC flow logs in CloudWatch for. Defaults to 180. | `string` | `180` | no |
| <a name="input_vpc_flow_log_traffic_type"></a> [vpc\_flow\_log\_traffic\_type](#input\_vpc\_flow\_log\_traffic\_type) | The type of traffic ('ACCEPT', 'REJECT', or 'ALL') to log. Defaults to 'ALL'. | `string` | `"ALL"` | no |
| <a name="input_vpc_instance_tenancy"></a> [vpc\_instance\_tenancy](#input\_vpc\_instance\_tenancy) | Tenancy of instances spun up within the VPC (`default`, `dedicated`).) | `string` | `"default"` | no |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | The name of the VPC. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_custom_vpce_dns_names"></a> [custom\_vpce\_dns\_names](#output\_custom\_vpce\_dns\_names) | Custom VPCE DNS Names |
| <a name="output_custom_vpce_sg_id"></a> [custom\_vpce\_sg\_id](#output\_custom\_vpce\_sg\_id) | Custom VPCE SG endpoint ID |
| <a name="output_ecr_dkr_domain_name"></a> [ecr\_dkr\_domain\_name](#output\_ecr\_dkr\_domain\_name) | ECR dkr domain name |
| <a name="output_interface_vpce_sg_id"></a> [interface\_vpce\_sg\_id](#output\_interface\_vpce\_sg\_id) | VPCE SG endpoint ID |
| <a name="output_no_proxy_list"></a> [no\_proxy\_list](#output\_no\_proxy\_list) | No\_proxy List |
| <a name="output_prefix_list_ids"></a> [prefix\_list\_ids](#output\_prefix\_list\_ids) | Prefix List ID's |
| <a name="output_ssm_iam_role_name"></a> [ssm\_iam\_role\_name](#output\_ssm\_iam\_role\_name) | SSM IAM Role Name |
| <a name="output_ssm_instance_profile_name"></a> [ssm\_instance\_profile\_name](#output\_ssm\_instance\_profile\_name) | SSM IAM instance profile Name |
| <a name="output_vpc"></a> [vpc](#output\_vpc) | VPC Details |
<!-- END_TF_DOCS -->
