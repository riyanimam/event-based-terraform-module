# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = 14

  tags = merge(
    var.tags,
    {
      Name        = "/aws/lambda/${var.function_name}"
      Environment = var.environment
    }
  )
}

# IAM Role
resource "aws_iam_role" "lambda" {
  name = "${var.function_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })

  tags = merge(
    var.tags,
    {
      Name        = "${var.function_name}-role"
      Environment = var.environment
    }
  )
}

# IAM Policy
resource "aws_iam_role_policy" "lambda" {
  name = "${var.function_name}-policy"
  role = aws_iam_role.lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = var.sqs_queue_arn
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "${aws_cloudwatch_log_group.lambda.arn}:*"
      }
    ]
  })
}

# Lambda Function
data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = var.source_path
  output_path = "${path.module}/files/${var.function_name}.zip"
}

resource "aws_lambda_function" "main" {
  filename                       = data.archive_file.lambda.output_path
  function_name                 = var.function_name
  role                         = aws_iam_role.lambda.arn
  handler                      = var.handler
  source_code_hash             = data.archive_file.lambda.output_base64sha256
  runtime                      = var.runtime
  timeout                      = var.timeout
  memory_size                  = var.memory_size
  reserved_concurrent_executions = var.reserved_concurrent_executions

  environment {
    variables = merge(
      var.environment_variables,
      {
        ENVIRONMENT = var.environment
      }
    )
  }

  tags = merge(
    var.tags,
    {
      Name        = var.function_name
      Environment = var.environment
    }
  )
}

# Event Source Mapping
resource "aws_lambda_event_source_mapping" "sqs" {
  event_source_arn = var.sqs_queue_arn
  function_name    = aws_lambda_function.main.arn
  batch_size       = 10
  enabled          = true

  depends_on = [
    aws_iam_role_policy.lambda
  ]
}
