resource "aws_sqs_queue" "event_queue" {
  count = var.event_source_type == "sqs" && var.create_event_source ? 1 : 0

  name                       = coalesce(var.sqs_queue_name, "${var.function_name}-queue")
  visibility_timeout_seconds = var.sqs_visibility_timeout
  message_retention_seconds  = var.sqs_message_retention_seconds
  receive_wait_time_seconds  = var.sqs_receive_wait_time_seconds

  redrive_policy = var.enable_dlq ? jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq[0].arn
    maxReceiveCount     = var.max_receive_count
  }) : null

  tags = merge(
    var.tags,
    {
      Name = coalesce(var.sqs_queue_name, "${var.function_name}-queue")
    }
  )
}

resource "aws_sqs_queue" "dlq" {
  count = var.event_source_type == "sqs" && var.create_event_source && var.enable_dlq ? 1 : 0

  name                      = "${coalesce(var.sqs_queue_name, var.function_name)}-dlq"
  message_retention_seconds = 1209600 # 14 days

  tags = merge(
    var.tags,
    {
      Name = "${coalesce(var.sqs_queue_name, var.function_name)}-dlq"
    }
  )
}
