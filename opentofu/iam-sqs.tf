resource "aws_sqs_queue_policy" "event_queue_policy" {
  count = var.event_source_type == "sqs" && var.create_event_source ? 1 : 0

  queue_url = aws_sqs_queue.event_queue[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = aws_sqs_queue.event_queue[0].arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_lambda_function.event_based_lambda.arn
          }
        }
      }
    ]
  })
}
