provider "aws" {
  profile    = "default"
  region     = "us-east-1"
}
data "aws_caller_identity" "current" {
}
data "aws_region" "current" {

}
output "awsRegion" {
  value = "${data.aws_region.current.name}"
}