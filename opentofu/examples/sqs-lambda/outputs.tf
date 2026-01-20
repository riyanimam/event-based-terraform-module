output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = module.sqs_lambda.lambda_function_arn
}

output "sqs_queue_url" {
  description = "URL of the SQS queue"
  value       = module.sqs_lambda.sqs_queue_url
}

output "sqs_dlq_url" {
  description = "URL of the DLQ"
  value       = module.sqs_lambda.sqs_dlq_url
}
