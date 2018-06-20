
#DynamodDB table for TF locks
resource "aws_dynamodb_table" "tf-locks-table" {
  name           = "TF-Locks-${var.project}"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
   name = "LockID"
   type = "S"
 }

}

data "template_file" "global_demo" {

  template = "$${template_var}"

  vars {
    template_var = "${var.global_demo_var}"
  }
}


resource "null_resource" "global_demo" {
  triggers = {
      global_demo_trigger = "${var.global_demo_var}"
  }

  provisioner "local-exec" {
    command = "( echo ${data.template_file.global_demo.rendered} )"
  }
}

output "global_admins"       { value = "${data.template_file.global_demo.rendered}" }
output "account_id" { value = "${data.aws_caller_identity.current.account_id}" }
