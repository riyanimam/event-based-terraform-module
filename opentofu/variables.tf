variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "lambda_runtime" {
  description = "Runtime for the Lambda function"
  type        = string
  default     = "python3.12"
}

variable "lambda_handler" {
  description = "Handler for the Lambda function"
  type        = string
  default     = "handler.lambda_handler"
}

variable "lambda_timeout" {
  description = "Timeout for the Lambda function in seconds"
  type        = number
  default     = 300
}

variable "lambda_memory_size" {
  description = "Memory size for the Lambda function in MB"
  type        = number
  default     = 128
}

variable "source_code_path" {
  description = "Path to the Lambda function source code (zip file)"
  type        = string
}

variable "event_source_type" {
  description = "Type of event source (sqs, dynamodb, kinesis, eventbridge)"
  type        = string
  default     = "sqs"

  validation {
    condition     = contains(["sqs", "dynamodb", "kinesis", "eventbridge"], var.event_source_type)
    error_message = "Event source type must be one of: sqs, dynamodb, kinesis, eventbridge"
  }
}

variable "event_source_arn" {
  description = "ARN of the event source (SQS queue, DynamoDB stream, Kinesis stream, or EventBridge rule)"
  type        = string
  default     = null
}

variable "create_event_source" {
  description = "Whether to create the event source (SQS queue, etc.) or use existing ARN"
  type        = bool
  default     = true
}

variable "batch_size" {
  description = "Batch size for event source mapping"
  type        = number
  default     = 10
}

variable "starting_position" {
  description = "Starting position for stream event sources (LATEST or TRIM_HORIZON)"
  type        = string
  default     = "LATEST"

  validation {
    condition     = contains(["LATEST", "TRIM_HORIZON"], var.starting_position)
    error_message = "Starting position must be either LATEST or TRIM_HORIZON"
  }
}

variable "environment_variables" {
  description = "Environment variables for the Lambda function"
  type        = map(string)
  default     = {}
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 14
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "sqs_queue_name" {
  description = "Name of the SQS queue (if creating new)"
  type        = string
  default     = null
}

variable "sqs_visibility_timeout" {
  description = "Visibility timeout for SQS queue in seconds"
  type        = number
  default     = 300
}

variable "sqs_message_retention_seconds" {
  description = "Message retention period for SQS queue in seconds"
  type        = number
  default     = 345600 # 4 days
}

variable "sqs_receive_wait_time_seconds" {
  description = "Receive wait time for SQS queue (long polling)"
  type        = number
  default     = 20
}

variable "enable_dlq" {
  description = "Enable Dead Letter Queue for SQS"
  type        = bool
  default     = true
}

variable "max_receive_count" {
  description = "Maximum number of receives before sending to DLQ"
  type        = number
  default     = 3
}

variable "kms_key_id" {
  description = "KMS key ID for encryption (for SQS and CloudWatch Logs)"
  type        = string
  default     = null
}

variable "enable_sqs_encryption" {
  description = "Enable server-side encryption for SQS queues"
  type        = bool
  default     = true
}

variable "lambda_reserved_concurrent_executions" {
  description = "Reserved concurrent executions for Lambda function (-1 for unreserved)"
  type        = number
  default     = -1
}

variable "eventbridge_event_pattern" {
  description = "Event pattern for EventBridge rule (JSON string)"
  type        = string
  default     = null
}

variable "eventbridge_schedule_expression" {
  description = "Schedule expression for EventBridge rule (e.g., 'rate(5 minutes)')"
  type        = string
  default     = null
}

# VPC Configuration (CKV_AWS_117)
variable "subnet_ids" {
  description = "List of subnet IDs for Lambda VPC configuration"
  type        = list(string)
  default     = []
}

variable "security_group_ids" {
  description = "List of security group IDs for Lambda VPC configuration"
  type        = list(string)
  default     = []
}

# X-Ray Tracing (CKV_AWS_50)
variable "enable_xray_tracing" {
  description = "Enable X-Ray tracing for Lambda function"
  type        = bool
  default     = true
}

# Dead Letter Queue (CKV_AWS_116)
variable "enable_lambda_dlq" {
  description = "Enable Dead Letter Queue for Lambda function"
  type        = bool
  default     = true
}

variable "lambda_dlq_retention_seconds" {
  description = "Message retention period for Lambda DLQ in seconds"
  type        = number
  default     = 1209600 # 14 days
}

# Code Signing (CKV_AWS_272)
variable "code_signing_config_arn" {
  description = "ARN of the Code Signing Config for Lambda"
  type        = string
  default     = null
}
