output "lambda_function_name" {
  description = "Lambda function name"
  value       = aws_lambda_function.this.function_name
}

output "api_gateway_endpoint" {
  description = "API Gateway endpoint"
  value       = aws_apigatewayv2_api.this[0].api_endpoint
}