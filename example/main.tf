provider "aws" {
  region = "eu-west-1"

  assume_role {
    role_arn = "arn:aws:iam::${local.account["development"]}:role/${var.assume_role}"
  }

}

variable "assume_role" {
  type        = string
  default     = "ci"
  description = "Role to assume"
}



module "vpc" {
  source = "../"

  vpc_name = "vpc-module-test"
  region   = "eu-west-1"

  vpc_cidr_block = "10.100.0.0/24"
}
