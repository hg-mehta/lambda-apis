variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "shared_infra_bucket_name" {
  description = "Shared infrastructure bucket name"
  type        = string
}

variable "shared_infra_dynamodb_table_name" {
  description = "Shared infrastructure DynamoDB table name"
  type        = string
}

variable "shared_infra_state_object_key" {
  description = "Shared infrastructure state object key"
  type        = string
}

variable "apis" {
  description = "APIs to deploy"
  type = map(object({
    function_name              = string
    source_path                = string
    output_path                = string
    runtime                    = string
    handler                    = string
    timeout                    = number
    memory_size                = number
    function_description       = string
    allowed_origins            = list(string)
    allowed_api_methods        = list(string)
    allowed_api_headers        = list(string)
    api_route_keys             = list(string)
    integration_method         = string
    integrate_with_api_gateway = bool
    environment_variables      = map(string)
    tags                       = map(string)
  }))
}
