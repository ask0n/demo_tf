#--- global.tf
#variable "bucket" {}
#variable "tfstate" {}
variable "global_demo_var" {
  default = "admin1"
}

#--- provider.tf

#--- s3_terraform.tf
variable "external_accounts" {
 default = {
  "terraform-demo" = 296786580913
 }
}
