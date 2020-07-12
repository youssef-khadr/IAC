output "cloudfront_domain_name" {
  value = "${aws_cloudfront_distribution.s3_distribution.domain_name}"
}

output "api_url" {
  value = "${aws_apigatewayv2_stage.poc_stage.invoke_url}"
}

