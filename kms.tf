
resource "aws_kms_key" "kmsKey" {
  description = "POC KMS Key"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  policy = <<POLICY
    {
        "Version": "2012-10-17",
        "Id": "key-consolepolicy-3",
        "Statement": [
            {
                "Sid": "Allow CloudFront Flow Logs to use the key",
                "Effect": "Allow",
                "Principal": {
                    "Service": "delivery.logs.amazonaws.com"
                },
                "Action": "kms:GenerateDataKey*",
                "Resource": "*"
            },
            {
                "Sid": "Enable IAM User Permissions",
                "Effect": "Allow",
                "Principal": {
                    "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
                },
                "Action": "kms:*",
                "Resource": "*"
            }
        ]
    }
    POLICY
}
resource "aws_kms_alias" "kmsAlias" {
  name          = "alias/poc-kms-key"
  target_key_id = "${aws_kms_key.kmsKey.key_id}"
}   