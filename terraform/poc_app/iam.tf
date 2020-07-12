# ecs iam role and policies
data "template_file" "ecs_role" {
  template = "${file("${path.module}/templates/ecs-role.json")}"
}

resource "aws_iam_role" "ecs_role" {
  name               = "ecs_role_${var.environment}"
  assume_role_policy = "${data.template_file.ecs_role.rendered}"
}

# Attach aws default roles to ECS
resource "aws_iam_role_policy_attachment" "ecs_instance_role_policy" {
  role       = "${aws_iam_role.ecs_role.id}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_service_role_policy" {
  role       = "${aws_iam_role.ecs_role.id}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

# # IAM profile to be used in auto-scaling launch configuration.
# resource "aws_iam_instance_profile" "ecs" {
#   name = "ecs-instance-profile-${var.environment}"
#   path = "/"
#   role = "${aws_iam_role.ecs_role.name}"
# }


# # IAM user for pulling poc config file from S3
# resource "aws_iam_user" "poc" {
#   name = "poc-${var.environment}"
# }

# resource "aws_iam_access_key" "poc" {
#   user = "${aws_iam_user.poc.name}"
# }

# resource "aws_iam_user_policy" "poc" {
#   name   = "poc_config_readonly_${var.environment}"
#   user   = "${aws_iam_user.poc.name}"
# //  todo: make this policy restricted to the config bucket
#   policy = <<EOF
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Effect": "Allow",
#             "Action": [
#                 "s3:Get*",
#                 "s3:List*"
#             ],
#             "Resource": "*"
#         }
#     ]
# }
# EOF
# }