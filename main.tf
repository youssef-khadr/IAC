provider "aws" {
  profile    = "default"
  region     = "us-east-1"
}
data "aws_caller_identity" "current" {
  
}
