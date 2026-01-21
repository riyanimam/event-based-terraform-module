resource "aws_cloudwatch_event_rule" "event_rule" {
  count = var.event_source_type == "eventbridge" && var.create_event_source ? 1 : 0

  name                = "${var.function_name}-rule"
  description         = "EventBridge rule for ${var.function_name}"
  event_pattern       = var.eventbridge_event_pattern
  schedule_expression = var.eventbridge_schedule_expression

  tags = var.tags
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  count = var.event_source_type == "eventbridge" && var.create_event_source ? 1 : 0

  rule      = aws_cloudwatch_event_rule.event_rule[0].name
  target_id = "lambda"
  arn       = aws_lambda_function.event_based_lambda.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  count = var.event_source_type == "eventbridge" && var.create_event_source ? 1 : 0

  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.event_based_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.event_rule[0].arn
}
