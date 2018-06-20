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
