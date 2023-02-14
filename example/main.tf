provider "aws" {
  region = "eu-west-1"
}

module "vpc" {
  source = "../"

  vpc_name = "vpc-module-test"
  region   = "eu-west-1"

  vpc_cidr_block = "10.100.0.0/24"
}
