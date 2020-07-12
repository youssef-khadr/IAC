
resource "aws_ecs_cluster" "main" {
  name = "poc-cluster-${var.environment}"
}
