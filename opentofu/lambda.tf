resource "aws_lambda_function" "event_based_lambda" {
  function_name = var.function_name
  filename      = var.source_code_path
  handler       = var.lambda_handler
  runtime       = var.lambda_runtime
  role          = aws_iam_role.lambda_execution.arn

  source_code_hash = filebase64sha256(var.source_code_path)

  timeout                        = var.lambda_timeout
  memory_size                    = var.lambda_memory_size
  reserved_concurrent_executions = var.lambda_reserved_concurrent_executions

  # VPC Configuration (CKV_AWS_117)
  dynamic "vpc_config" {
    for_each = length(var.subnet_ids) > 0 ? [1] : []
    content {
      subnet_ids         = var.subnet_ids
      security_group_ids = var.security_group_ids
    }
  }

  # X-Ray Tracing (CKV_AWS_50)
  tracing_config {
    mode = var.enable_xray_tracing ? "Active" : "PassThrough"
  }

  # Dead Letter Queue (CKV_AWS_116)
  dynamic "dead_letter_config" {
    for_each = var.enable_lambda_dlq ? [1] : []
    content {
      target_arn = aws_sqs_queue.lambda_dlq[0].arn
    }
  }

  # Environment variables with encryption (CKV_AWS_173)
  environment {
    variables = var.environment_variables
  }

  # Code Signing (CKV_AWS_272)
  code_signing_config_arn = var.code_signing_config_arn != null ? var.code_signing_config_arn : null

  tags = merge(
    var.tags,
    {
      Name = var.function_name
    }
  )
}

# Dead Letter Queue for Lambda (CKV_AWS_116)
resource "aws_sqs_queue" "lambda_dlq" {
  count = var.enable_lambda_dlq ? 1 : 0

  name                      = "${var.function_name}-dlq"
  message_retention_seconds = var.lambda_dlq_retention_seconds
  kms_master_key_id         = var.kms_key_id

  tags = merge(
    var.tags,
    {
      Name = "${var.function_name}-dlq"
    }
  )
}

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = var.log_retention_days != 0 ? (var.log_retention_days < 365 ? 365 : var.log_retention_days) : 0
  kms_key_id        = var.kms_key_id

  tags = merge(
    var.tags,
    {
      Name = "${var.function_name}-logs"
    }
  )
}

resource "aws_lambda_event_source_mapping" "event_mapping" {
  count = var.event_source_type != "eventbridge" ? 1 : 0

  event_source_arn = var.create_event_source && var.event_source_type == "sqs" ? aws_sqs_queue.event_queue[0].arn : var.event_source_arn
  function_name    = aws_lambda_function.event_based_lambda.arn
  enabled          = true
  batch_size       = var.batch_size

  starting_position = var.event_source_type != "sqs" ? var.starting_position : null
}
