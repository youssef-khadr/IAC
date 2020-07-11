resource "aws_ecs_cluster" "main" {
  name = "poc-cluster-${var.environment}"
}

data "template_file" "poc_app" {
  template = "${file("${path.module}/poc_app.json")}"

  vars = {
    environment           = "${var.environment}"
    aws_region            = "${var.aws_region}"
    app_image             = "${aws_ecr_repository.poc.repository_url}"
    fargate_cpu           = "${var.fargate_cpu}"
    fargate_memory        = "${var.fargate_memory}"
    db_url_fa             = "${var.db_url_fa}"
    db_url_ro             = "${var.db_url_ro}"
    db_username           = "${var.db_username}"
    db_password           = "${var.db_password}"
    app_port              = "${var.app_port}"
    s3_config_bucket_name = "${aws_s3_bucket.poc-config.id}"
  }
}

resource "aws_ecs_task_definition" "poc" {
  family                   = "poc-task-${var.environment}"
  execution_role_arn       = "${aws_iam_role.ecs_role.arn}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "${var.fargate_cpu}"
  memory                   = "${var.fargate_memory}"
  container_definitions    = "${data.template_file.poc_app.rendered}"
  # task_role_arn            = "${aws_iam_role.ecs_role.arn}"
}

resource "aws_ecs_service" "main" {
  name            = "poc-service-${var.environment}"
  cluster         = "${aws_ecs_cluster.main.id}"
  task_definition = "${aws_ecs_task_definition.poc.arn}"
  desired_count   = "${var.desired_containers}"
  launch_type     = "FARGATE"
  # iam_role        = "aws_iam_role_policy.ecs_service_role_policy.arn"

  network_configuration {
    security_groups  = ["${aws_security_group.ecs_tasks.id}"]
    subnets          = "${var.vpc_subnets}"
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.app.id}"
    container_name   = "poc-${var.environment}"
    container_port   = "${var.app_port}"
  }

  depends_on = [
    aws_alb_listener.front_end
  ]
}