output "api_gateway_contact_endpoint" {
  description = "Full API Gateway contact endpoint URL"
  value       = "${data.terraform_remote_state.shared_infra.outputs.api_domain_id}/contact"
}

output "lambda_function_names" {
  description = "Lambda function name"
  value       = { for k, v in module.lambdas : k => v.lambda_function_name }
}

output "api_gateway_endpoints" {
  description = "API Gateway endpoints"
  value       = { for k, v in module.lambdas : k => v.api_gateway_endpoint }
}