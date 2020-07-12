# ALB Security Group: Edit this to restrict access to the application
resource "aws_security_group" "lb" {
  name        = "poc-load-balancer-security-group-${var.environment}"
  description = "controls access to the ALB"
  vpc_id      = var.vpc_id
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

