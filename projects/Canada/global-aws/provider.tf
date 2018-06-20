/*
provider "aws" {
  region = "${var.region}"
  profile = "${var.aws_profile}"
  assume_role {
    role_arn     = "arn:aws:iam::XXXXXXXXXXXX:role/OrganizationAccountAccessRole"
    session_name = "Terraform-Canada-global"
  }
}
*/
terraform {
    required_version = "~> 0.10.8"
    backend "s3" {
      dynamodb_table = "TF-Locks-demo"
    }
}

provider "aws" {
  version = "~> 1.23"
  region = "${var.region}"
  profile = "${var.aws_profile}"
}

data "aws_caller_identity" "current" {}
