data "aws_region" "current" {}

data "aws_caller_identity" "current_user" {}

data "aws_arn" "user_resource" {
  arn = "${data.aws_caller_identity.current_user.arn}"
}

locals {
  current_user_name = "${data.aws_arn.user_resource.resource}"
  default_tags = "${map(
    "Project", "Claims",
    "Environment", "${var.environment}",
    "Region", "${data.aws_region.current.name}",
    "Account", "${data.aws_caller_identity.current_user.account_id}",
    "CreatedBy", "${local.current_user_name}"
  )}"
}

# ---------------------
# Example usage of tags
# ---------------------
# resource "aws_instance" "master" {
#   //  Use our common tags and add a specific name.
#   tags = "${merge(
#     local.default_tags,
#     map(
#       "Name", "OpenShift Master"
#     )
#   )}"
# }