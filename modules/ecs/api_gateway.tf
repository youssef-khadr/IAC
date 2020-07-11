resource "aws_apigatewayv2_api" "poc_api" {
  name          = "POC API"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_vpc_link" "poc_vpc_link" {
  name               = "POCVPC"
  security_group_ids = [aws_security_group.ecs_tasks.id]
  subnet_ids         = var.vpc_subnets
}

resource "aws_apigatewayv2_integration" "private_resource" {
  api_id           = "${aws_apigatewayv2_api.poc_api.id}"
  integration_type = "HTTP_PROXY"
  connection_type = "VPC_LINK"
  integration_uri = aws_alb_listener.front_end.id
  connection_id = aws_apigatewayv2_vpc_link.poc_vpc_link.id
  integration_method = "GET"
}

resource "aws_apigatewayv2_route" "poc_route" {
  api_id    = "${aws_apigatewayv2_api.poc_api.id}"
  route_key = "GET /"
  target = "integrations/${aws_apigatewayv2_integration.private_resource.id}"
}

resource "aws_apigatewayv2_stage" "poc_stage" {
  api_id = "${aws_apigatewayv2_api.poc_api.id}"
  name   = "$default"
  #deployment_id = aws_apigatewayv2_deployment.poc_deployment.id
  auto_deploy = true
}

# resource "aws_apigatewayv2_deployment" "poc_deployment" {
#   api_id      = "${aws_apigatewayv2_api.poc_api.id}"
#   description = "Example deployment"

#   lifecycle {
#     create_before_destroy = true
#   }
# }


# 