resource "aws_ecr_repository" "poc" {
  name = "poc-app"

  image_scanning_configuration {
    scan_on_push = true
  }
}