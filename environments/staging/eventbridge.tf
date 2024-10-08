resource "aws_cloudwatch_event_rule" "daily_7am" {
  name        = "daily_7am"
  description = "毎朝7時に実行"
  # デフォルトはUTC時間、日本時間は+9時間
  schedule_expression = "cron(0 22 * * ? *)"
}

resource "aws_cloudwatch_event_target" "lambda_scheduled_task" {
  rule      = aws_cloudwatch_event_rule.daily_7am.name
  target_id = "run-scheduled-task-every-day-7am"
  arn       = aws_lambda_function.hn_ruby.arn
}
