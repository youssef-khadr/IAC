# ALB Security Group: Edit this to restrict access to the application
resource "aws_security_group" "lb" {
  name        = "poc-load-balancer-security-group-${var.environment}"
  description = "controls access to the ALB"
  vpc_id      = "${data.aws_vpc.main.id}"
  tags        = "${merge(
       local.default_tags,
       map(
         "Name", "poc Load Balancer Security Group ${var.environment}"
       )
     )}"

  ingress {
    from_port   = "${var.app_port}"
    to_port     = "${var.app_port}"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Traffic to the ECS cluster should only come from the ALB
resource "aws_security_group" "ecs_tasks" {
  name        = "poc-ecs-tasks-security-group-${var.environment}"
  description = "allow inbound access from the ALB only"
  vpc_id      = "${data.aws_vpc.main.id}"
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
#    security_groups = ["${aws_security_group.lb.id}"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
