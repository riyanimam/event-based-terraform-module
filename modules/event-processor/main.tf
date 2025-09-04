# SQS Queue
resource "aws_sqs_queue" "main" {
  name                       = var.sqs_queue_name
  message_retention_seconds  = var.sqs_message_retention_seconds
  visibility_timeout_seconds = var.sqs_visibility_timeout_seconds

  # Enable server-side encryption
  sqs_managed_sse_enabled = true

  # Add a dead-letter queue configuration
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = 3
  })

  tags = merge(
    var.tags,
    {
      Name        = var.sqs_queue_name
      Environment = var.environment
      Project     = var.project
    }
  )
}

# Dead Letter Queue
resource "aws_sqs_queue" "dlq" {
  name                       = "${var.sqs_queue_name}-dlq"
  message_retention_seconds  = 1209600 # 14 days
  visibility_timeout_seconds = var.sqs_visibility_timeout_seconds

  sqs_managed_sse_enabled = true

  tags = merge(
    var.tags,
    {
      Name        = "${var.sqs_queue_name}-dlq"
      Environment = var.environment
      Project     = var.project
    }
  )
}

# CloudWatch Log Group for Lambda
resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 14

  tags = merge(
    var.tags,
    {
      Name        = "/aws/lambda/${var.lambda_function_name}"
      Environment = var.environment
      Project     = var.project
    }
  )
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda" {
  name = "${var.lambda_function_name}-role"

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
      Name        = "${var.lambda_function_name}-role"
      Environment = var.environment
      Project     = var.project
    }
  )
}

# IAM Policy for Lambda to access SQS and CloudWatch Logs
resource "aws_iam_role_policy" "lambda" {
  name = "${var.lambda_function_name}-policy"
  role = aws_iam_role.lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:ChangeMessageVisibility"
        ]
        Resource = [
          aws_sqs_queue.main.arn,
          aws_sqs_queue.dlq.arn
        ]
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
  source_dir  = var.lambda_source_path
  output_path = "${path.module}/files/${var.lambda_function_name}.zip"
}

resource "aws_lambda_function" "main" {
  filename                       = data.archive_file.lambda.output_path
  function_name                 = var.lambda_function_name
  role                         = aws_iam_role.lambda.arn
  handler                      = var.lambda_handler
  source_code_hash             = data.archive_file.lambda.output_base64sha256
  runtime                      = var.lambda_runtime
  timeout                      = var.lambda_timeout
  memory_size                  = var.lambda_memory_size
  reserved_concurrent_executions = var.lambda_reserved_concurrent_executions

  environment {
    variables = {
      ENVIRONMENT = var.environment
      SQS_QUEUE_URL = aws_sqs_queue.main.url
      DLQ_URL = aws_sqs_queue.dlq.url
    }
  }

  tags = merge(
    var.tags,
    {
      Name        = var.lambda_function_name
      Environment = var.environment
      Project     = var.project
    }
  )
}

# Event Source Mapping
resource "aws_lambda_event_source_mapping" "sqs" {
  event_source_arn = aws_sqs_queue.main.arn
  function_name    = aws_lambda_function.main.arn
  batch_size       = 10
  enabled          = true

  depends_on = [
    aws_iam_role_policy.lambda
  ]
}
