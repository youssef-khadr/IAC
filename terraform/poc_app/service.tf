resource "aws_ecs_service" "main" {
  name            = "poc-service-${var.environment}"
  cluster         = var.ecs_cluster_id
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
    target_group_arn = var.target_group_arn
    container_name   = "poc-${var.environment}"
    container_port   = "${var.app_port}"
  }
}