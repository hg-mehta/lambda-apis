module "lambdas" {
  source                     = "./modules/lambda"
  for_each                   = toset(keys(var.apis))
  function_name              = var.apis[each.value].function_name
  source_path                = var.apis[each.value].source_path
  output_path                = var.apis[each.value].output_path
  runtime                    = var.apis[each.value].runtime
  handler                    = var.apis[each.value].handler
  timeout                    = var.apis[each.value].timeout
  memory_size                = var.apis[each.value].memory_size
  function_description       = var.apis[each.value].function_description
  allowed_origins            = var.apis[each.value].allowed_origins
  allowed_api_methods        = var.apis[each.value].allowed_api_methods
  allowed_api_headers        = var.apis[each.value].allowed_api_headers
  api_route_keys             = var.apis[each.value].api_route_keys
  integration_method         = var.apis[each.value].integration_method
  integrate_with_api_gateway = var.apis[each.value].integrate_with_api_gateway
  api_domain_name            = data.terraform_remote_state.shared_infra.outputs.api_domain_id
  environment_variables = var.apis[each.value].environment_variables
  tags = merge(var.apis[each.value].tags, {
    Environment = var.environment
  })
}
