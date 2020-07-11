resource "aws_ecr_repository" "ecrRepository" {
  name                 = "poc-repo"

  image_scanning_configuration {
    scan_on_push = true
  }
}
output "ecrRepositoryURL" {
  value = "${aws_ecr_repository.ecrRepository.repository_url}"
}