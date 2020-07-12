data "template_file" "poc_app" {
  template = "${file("${path.module}/templates/poc_app.json")}"

  vars = {
    environment           = "${var.environment}"
    aws_region            = "${var.aws_region}"
    app_image             = "${var.ecr_repo_url}"
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

