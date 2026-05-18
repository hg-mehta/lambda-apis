data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../../../${var.source_path}"
  output_path = "${path.module}/../../../${var.output_path}"
}

resource "aws_iam_role" "this" {
  name = "${var.function_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.function_name}-lambda-role"
  })
}

resource "aws_lambda_function" "this" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = var.function_name
  role             = aws_iam_role.this.arn
  handler          = var.handler
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = var.runtime
  timeout          = var.timeout
  memory_size      = var.memory_size

  environment {
    variables = var.environment_variables
  }

  tags = var.tags
}

resource "aws_lambda_permission" "api_gateway" {
  count         = var.integrate_with_api_gateway ? 1 : 0
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.this[0].execution_arn}/*/*"
}

resource "aws_apigatewayv2_api_mapping" "api" {
  count       = var.integrate_with_api_gateway ? 1 : 0
  api_id      = aws_apigatewayv2_api.this[0].id
  domain_name = var.api_domain_name
  stage       = aws_apigatewayv2_stage.default.id
}

# Integrate with API Gateway
resource "aws_apigatewayv2_api" "this" {
  count         = var.integrate_with_api_gateway ? 1 : 0
  name          = "${var.function_name}-api"
  protocol_type = "HTTP"
  description   = var.function_description

  cors_configuration {
    allow_origins = length(var.allowed_origins) > 0 ? var.allowed_origins : ["*"]
    allow_methods = var.allowed_api_methods
    allow_headers = var.allowed_api_headers
    max_age       = 300
  }

  tags = var.tags
}

resource "aws_apigatewayv2_integration" "this" {
  count            = var.integrate_with_api_gateway ? 1 : 0
  api_id           = aws_apigatewayv2_api.this[0].id
  integration_type = "AWS_PROXY"

  integration_method     = var.integration_method
  integration_uri        = aws_lambda_function.this.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "routes" {
  for_each  = var.integrate_with_api_gateway ? toset(var.api_route_keys) : toset([])
  api_id    = aws_apigatewayv2_api.this[0].id
  route_key = each.value
  target    = "integrations/${aws_apigatewayv2_integration.this[0].id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.this[0].id
  name        = "$default"
  auto_deploy = true

  default_route_settings {
    throttling_rate_limit  = 10
    throttling_burst_limit = 5
  }

  tags = var.tags
}

resource "aws_iam_role_policy" "lambda_contact_logs" {
  name = "${var.function_name}-lambda-logs-policy"
  role = aws_iam_role.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${aws_lambda_function.this.function_name}"
  retention_in_days = 7

  tags = merge(var.tags, {
    Name = "${var.function_name}-lambda-logs"
  })
}