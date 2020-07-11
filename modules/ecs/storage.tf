resource "aws_s3_bucket" "poc-config" {
  bucket = "poc-claims-config-${var.environment}-${data.aws_caller_identity.current_user.account_id}"
  acl    = "private"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "AES256"
      }
    }
  }
  versioning {
    enabled = true
  }

  tags   = "${merge(
       local.default_tags,
       map(
         "Name", "poc Config Bucket ${var.environment}"
       )
     )}"
}

resource "aws_s3_bucket" "static_data" {
  bucket = "ifbi-poc-static-data-us-east-1"
  acl    = "private"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_policy" "staticS3BucketPolicy" {
  bucket = "${aws_s3_bucket.static_data.id}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "CloudFrontReadForGetAndListBucketObjects",
      "Effect": "Allow",
      "Principal":{ 
        "AWS": "${aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn}"
      },
      "Action":[
        "s3:GetObject"
      ],
      "Resource": "${aws_s3_bucket.static_data.arn}/*"
    }
  ]
}
POLICY
}
resource "aws_s3_bucket_public_access_block" "staticS3PublicAccess" {
  bucket = "${aws_s3_bucket.static_data.id}"

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "cfLogsS3" {
  bucket = "ifbi-poc-cf-logs-us-east-1"
  acl    = "private"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "cfLogsS3PublicAccess" {
  bucket = "${aws_s3_bucket.cfLogsS3.id}"

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
