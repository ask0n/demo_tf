module "vpc" {
#  source = "../../../modules/aws/vpc/"
  source = "git::https://github.com/ask0n/tf_aws.git?ref=aws-v10.1-0.2//vpc"

  #Global variables:
  name           = "${var.name}"
  region         = "${var.region}"
  project        = "${var.project}"
  environment    = "${var.environment}"

  input_variable = "${var.demo_var1}"
  global_input_variable = "${data.terraform_remote_state.global_state.global_admins}"

}

module "vpc1" {
#  source = "../../../modules/aws/vpc/"
  source = "git::https://github.com/ask0n/tf_aws.git?ref=aws-v10.1-0.3//vpc"

  #Global variables:
  name           = "${var.name}"
  region         = "${var.region}"
  project        = "${var.project}"
  environment    = "${var.environment}"

  input_variable = "${var.demo_var2}"
  global_input_variable = "${data.terraform_remote_state.global_state.global_admins}"

}
