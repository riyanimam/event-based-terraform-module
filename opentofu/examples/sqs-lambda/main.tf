module "sqs_lambda" {
  source = "../../"

  function_name      = var.function_name
  lambda_runtime     = "python3.12"
  lambda_handler     = "handler.lambda_handler"
  lambda_timeout     = 60
  lambda_memory_size = 256

  source_code_path = "${path.module}/lambda.zip"

  event_source_type   = "sqs"
  create_event_source = true
  sqs_queue_name      = "${var.function_name}-queue"

  batch_size                    = 10
  sqs_visibility_timeout        = 300
  sqs_message_retention_seconds = 345600
  sqs_receive_wait_time_seconds = 20
  enable_dlq                    = true
  max_receive_count             = 3

  environment_variables = {
    LOG_LEVEL   = "INFO"
    ENVIRONMENT = var.environment
  }

  log_retention_days = 7

  tags = {
    Example = "SQS-Lambda"
    Owner   = "DevOps"
  }
}
