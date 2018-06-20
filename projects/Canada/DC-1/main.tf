data "terraform_remote_state" "global_state" {
  backend = "s3"

  config {
    bucket = "${var.bucket}"
    region = "${var.region}"
    key    = "Canada-global-aws.tfstate"
    profile = "${var.aws_profile}"
  }
}

#Show output information after apply
output "configuration" {
  value = <<CONFIGURATION

Info:
MODULE:  ${module.vpc.vpc_id}
MODULE1:  ${module.vpc1.vpc_id}
GLOBAL: ${data.terraform_remote_state.global_state.global_admins}

CONFIGURATION
}
