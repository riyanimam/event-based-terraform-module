resource "aws_lambda_function" "event_based_lambda" {
  function_name = var.function_name
  filename      = var.source_code_path
  handler       = var.lambda_handler
  runtime       = var.lambda_runtime
  role          = aws_iam_role.lambda_execution.arn

  source_code_hash = filebase64sha256(var.source_code_path)

  timeout     = var.lambda_timeout
  memory_size = var.lambda_memory_size

  environment {
    variables = var.environment_variables
  }

  tags = merge(
    var.tags,
    {
      Name = var.function_name
    }
  )
}

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = var.log_retention_days

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
