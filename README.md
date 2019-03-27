# terraform-aws-vpc
A Terraform module to create an AWS VPC with consistent features

## Usage

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

resource "aws_subnet" "main" {
  vpc_id            = "${module.vpc.vpc_id}"
  cidr_block        = "${module.vpc.vpc_cidr_block}"
  availability_zone = "eu-west-2a"
}
```

### Gateway Endpoint Configuration

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

resource "aws_subnet" "main" {
  vpc_id            = "${module.vpc.vpc_id}"
  cidr_block        = "${module.vpc.vpc_cidr_block}"
  availability_zone = "eu-west-2a"
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

* s3
* [EMR docs](https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-clusters-in-a-vpc.html)

#### EMR with EMRFS

* s3
* dynamodb
* [EMR docs](https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-clusters-in-a-vpc.html)

#### EMR with Debugging

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
