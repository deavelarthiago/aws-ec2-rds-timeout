#IAM Role and Policy for Lambda Functions
resource "aws_iam_role" "lambda_rds_role" {
  name = "lambda_rds_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
    }]
  })
}

resource "aws_iam_role_policy" "lambda_rds_policy" {
  name = "lambda_rds_policy"
  role = aws_iam_role.lambda_rds_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "rds:StartDBInstance",
          "rds:StopDBInstance",
          "rds:DescribeDBInstances"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
    ]
  })
}

#Lambda function for stopping RDS Insance
resource "aws_lambda_function" "rds_stop" {
  function_name    = "rds_stop"
  role             = aws_iam_role.lambda_rds_role.arn
  handler          = "lambda_function_stop.lambda_handler"
  runtime          = "python3.8"
  filename         = "${path.module}/lambda_function_stop.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda_function_stop.zip")
}

#CloudWatch Event Rule to schedule stopping of RDS instances
resource "aws_cloudwatch_event_rule" "schedule_rds_stop" {
  name                = "schedule_rds_stop"
  schedule_expression = "cron(<Insert the schedule here according to your needs to stop the RDS Instance>)
"
}

#CloudWatch Event Target and Lambda Permission for stopping RDS instance
resource "aws_cloudwatch_event_target" "target_rds_stop" {
  rule      = aws_cloudwatch_event_rule.schedule_rds_stop.name
  target_id = "TargetRdsStop"
  arn       = aws_lambda_function.rds_stop.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_rds_stop" {
  statement_id  = "AllowCloudWatchToCallRdsStop"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rds_stop.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.schedule_rds_stop.arn
}

#Lambda function for starting RDS Insance
resource "aws_lambda_function" "rds_start" {
  function_name    = "rds_start"
  role             = aws_iam_role.lambda_rds_role.arn
  handler          = "lambda_function_start.lambda_handler"
  runtime          = "python3.8"
  filename         = "${path.module}/lambda_function_start.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda_function_start.zip")
}

#CloudWatch Event Rule to schedule starting of RDS instances
resource "aws_cloudwatch_event_rule" "schedule_rds_start" {
  name                = "schedule_rds_start"
  schedule_expression = "cron(<Insert the schedule here according to your needs to start the RDS Instance>)"
}

#CloudWatch Event Target and Lambda Permission for starting RDS instance
resource "aws_cloudwatch_event_target" "target_rds_start" {
  rule      = aws_cloudwatch_event_rule.schedule_rds_start.name
  target_id = "TargetRdsStart"
  arn       = aws_lambda_function.rds_start.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_rds_start" {
  statement_id  = "AllowCloudWatchToCallRdsStart"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rds_start.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.schedule_rds_start.arn
}