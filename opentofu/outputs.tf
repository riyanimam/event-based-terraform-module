output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.event_based_lambda.arn
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.event_based_lambda.function_name
}

output "lambda_function_invoke_arn" {
  description = "Invoke ARN of the Lambda function"
  value       = aws_lambda_function.event_based_lambda.invoke_arn
}

output "lambda_function_qualified_arn" {
  description = "Qualified ARN of the Lambda function"
  value       = aws_lambda_function.event_based_lambda.qualified_arn
}

output "lambda_role_arn" {
  description = "ARN of the Lambda execution role"
  value       = aws_iam_role.lambda_execution.arn
}

output "lambda_role_name" {
  description = "Name of the Lambda execution role"
  value       = aws_iam_role.lambda_execution.name
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.lambda_logs.name
}

output "cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.lambda_logs.arn
}

output "event_source_mapping_id" {
  description = "ID of the event source mapping"
  value       = try(aws_lambda_event_source_mapping.event_mapping[0].id, null)
}

output "sqs_queue_arn" {
  description = "ARN of the SQS queue (if created)"
  value       = try(aws_sqs_queue.event_queue[0].arn, null)
}

output "sqs_queue_url" {
  description = "URL of the SQS queue (if created)"
  value       = try(aws_sqs_queue.event_queue[0].url, null)
}

output "sqs_dlq_arn" {
  description = "ARN of the SQS DLQ (if created)"
  value       = try(aws_sqs_queue.dlq[0].arn, null)
}

output "sqs_dlq_url" {
  description = "URL of the SQS DLQ (if created)"
  value       = try(aws_sqs_queue.dlq[0].url, null)
}
