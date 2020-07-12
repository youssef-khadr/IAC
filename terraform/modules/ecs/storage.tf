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

