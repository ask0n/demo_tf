
#Create buckets for external accounts and grant access to them
resource "aws_s3_bucket" "remote_state_buckets" {
    count = "${length(keys(var.external_accounts))}"
    bucket = "${element(keys(var.external_accounts), count.index)}-${element(values(var.external_accounts), count.index)}"
    force_destroy = false
    versioning { enabled = true }
    policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${element(values(var.external_accounts), count.index)}:root"
            },
            "Action": "s3:ListBucket",
            "Resource": "arn:aws:s3:::${element(keys(var.external_accounts), count.index)}-${element(values(var.external_accounts), count.index)}"
        },
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${element(values(var.external_accounts), count.index)}:root"
            },
            "Action": [
                "s3:PutObject",
                "s3:GetObject"
            ],
            "Resource": "arn:aws:s3:::${element(keys(var.external_accounts), count.index)}-${element(values(var.external_accounts), count.index)}/*"
        }
    ]
}
POLICY
}
