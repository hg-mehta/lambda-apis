
variable "function_name" {
  description = "Lambda function name"
  type        = string
  default     = "contact"
}

variable "environment_variables" {
  description = "Environment variables for the Lambda function"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags for the Lambda function"
  type        = map(string)
  default     = {}
}

variable "source_path" {
  description = "Path to the source code for the Lambda function"
  type        = string
}

variable "output_path" {
  description = "Path to the source code for the Lambda function"
  type        = string
}

variable "runtime" {
  description = "Runtime for the Lambda function"
  type        = string
  default     = "nodejs24.x"
}

variable "handler" {
  description = "Handler for the Lambda function"
  type        = string
  default     = "index.handler"
}

variable "timeout" {
  description = "Timeout for the Lambda function"
  type        = number
  default     = 5
}

variable "memory_size" {
  description = "Memory size for the Lambda function"
  type        = number
  default     = 128
}

variable "function_description" {
  description = "Description for the Lambda function"
  type        = string
  default     = "Lambda function for the portfolio website"
}

variable "allowed_origins" {
  description = "Allowed CORS origins for API Gateway"
  type        = list(string)
  default     = []
}

variable "allowed_api_methods" {
  description = "Allowed API methods for the API Gateway"
  type        = list(string)
  default     = ["POST", "OPTIONS"]
}

variable "allowed_api_headers" {
  description = "Allowed API headers for the API Gateway"
  type        = list(string)
  default     = ["content-type"]
}

variable "api_route_keys" {
  description = "Route keys for the API Gateway"
  type        = list(string)
  default     = ["POST /contact", "OPTIONS /contact"]
}

variable "integration_method" {
  description = "Integration method for the API Gateway"
  type        = string
  default     = "POST"
}

variable "integrate_with_api_gateway" {
  description = "Integrate with API Gateway"
  type        = bool
  default     = true
}

variable "api_domain_name" {
  description = "API domain name"
  type        = string
}