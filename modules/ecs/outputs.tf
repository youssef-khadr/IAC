output "loadbalancer_url" {
  value = "${aws_alb.main.dns_name}"
}

output "poc_repo" {
  value = "${aws_ecr_repository.poc.repository_url}"
}

output "api_url" {
  value = "${aws_apigatewayv2_stage.poc_stage.invoke_url}"
}

output "cloudfront_domain_name" {
  value = "${aws_cloudfront_distribution.s3_distribution.domain_name}"
}

