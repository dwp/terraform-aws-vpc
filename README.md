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
  interface_vpce_source_security_group_count = 1
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

```
module "vpc" {
  source                                     = "dwp/vpc/aws"
  vpc_name                                   = "main"
  region                                     = "eu-west-2"
  vpc_cidr_block                             = "192.168.0.0/24"
  interface_vpce_source_security_group_count = 1
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
