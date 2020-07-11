resource "aws_alb" "main" {
  name            = "poc-load-balancer-${var.environment}"
  internal        = true
  subnets         = var.vpc_subnets
  security_groups = ["${aws_security_group.lb.id}"]
  idle_timeout    = 300
  tags            = "${merge(
       local.default_tags,
       map(
         "Name", "poc Load Balancer ${var.environment}"
       )
     )}"
}

resource "aws_alb_target_group" "app" {
  name        = "poc-target-group-${var.environment}"
  port        = var.app_port
  protocol    = "HTTP"
  vpc_id      = "${data.aws_vpc.main.id}"
  target_type = "ip"
  tags = "${merge(
       local.default_tags,
       map(
         "Name", "poc Load Balancer Target Group ${var.environment}"
       )
     )}"

  health_check {
    healthy_threshold   = "2"
    unhealthy_threshold = "2"
    interval            = "20"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "${var.health_check_path}"
  }
}

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "front_end" {
  load_balancer_arn = "${aws_alb.main.id}"
  port              = "${var.app_port}"
  protocol          = "HTTP"
  #ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  #certificate_arn   = "${var.https_cert_arn}"

  default_action {
    target_group_arn = "${aws_alb_target_group.app.id}"
    type             = "forward"
  }
}