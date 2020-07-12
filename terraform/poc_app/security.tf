
# Traffic to the ECS cluster should only come from the ALB
resource "aws_security_group" "api_gw_private_link" {
  name        = "poc-api-gw-private-link-security-group"
  description = "allow access on port 80 from the VPC link"
  vpc_id      = var.vpc_id
  tags        = "${merge(
       local.default_tags,
       map(
         "Name", "API Gateway VPC Link Security Group"
       )
     )}"

  ingress {
    protocol    = "tcp"
    from_port   = "${var.app_port}"
    to_port     = "${var.app_port}"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Traffic to the ECS cluster should only come from the ALB
resource "aws_security_group" "ecs_tasks" {
  name        = "poc-ecs-tasks-security-group"
  description = "allow inbound access from the ALB only"
  vpc_id      = var.vpc_id
  tags        = "${merge(
       local.default_tags,
       map(
         "Name", "poc ECS Security Group"
       )
     )}"

  ingress {
    protocol        = "tcp"
    from_port       = "${var.app_port}"
    to_port         = "${var.app_port}"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
