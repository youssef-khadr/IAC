# IAM user for pulling poc config file from S3
resource "aws_iam_user" "poc" {
  name = "poc-${var.environment}"
}

resource "aws_iam_access_key" "poc" {
  user = "${aws_iam_user.poc.name}"
}

resource "aws_iam_user_policy" "poc" {
  name   = "poc_config_readonly_${var.environment}"
  user   = "${aws_iam_user.poc.name}"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:Get*",
                "s3:List*"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}