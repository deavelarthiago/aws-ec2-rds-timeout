#IAM Role and Policy for Lambda Functions
resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"

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

resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda_policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "ec2:StopInstances",  
          "ec2:StartInstances"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
    ]
  })
}

#Lambda function for stopping EC2 Instance
resource "aws_lambda_function" "stop_ec2_instance" {
  function_name = "stop_ec2_instance"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function_stop.lambda_handler"
  runtime       = "python3.8"
  filename      = "${path.module}/lambda_function_stop.zip"

  source_code_hash = filebase64sha256("${path.module}/lambda_function_stop.zip")
}

#CloudWatch Event Rule and Target for Stopping EC2 Instance
resource "aws_cloudwatch_event_rule" "stop_ec2_schedule" {
  name                = "stop_ec2_schedule"
  description         = "Schedule to stop EC2 instance"
  schedule_expression = "cron(<Insert the schedule here according to your needs to start the Instance>)"
}

resource "aws_cloudwatch_event_target" "stop_ec2_target" {
  rule      = aws_cloudwatch_event_rule.stop_ec2_schedule.name
  target_id = "stopEC2Instance"
  arn       = aws_lambda_function.stop_ec2_instance.arn
}

#Lambda Permission for CloudWatch to Trigger Stop EC2 Lambda
resource "aws_lambda_permission" "allow_cloudwatch_to_call_stop_ec2" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.stop_ec2_instance.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.stop_ec2_schedule.arn
}

#Lambda function for starting EC2 Instance
resource "aws_lambda_function" "start_ec2_instance" {
  function_name    = "start_ec2_instance"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function_start.lambda_handler"
  runtime          = "python3.8"
  filename         = "${path.module}/lambda_function_start.zip"

  source_code_hash = filebase64sha256("${path.module}/lambda_function_start.zip")
}

#CloudWatch Event Rule and Target for Starting EC2 Instance
resource "aws_cloudwatch_event_target" "start_ec2_target" {
  rule      = aws_cloudwatch_event_rule.start_ec2_schedule.name
  target_id = "startEC2Instance"
  arn       = aws_lambda_function.start_ec2_instance.arn
}

resource "aws_cloudwatch_event_rule" "start_ec2_schedule" {
  name                = "start_ec2_schedule"
  description         = "Schedule to start EC2 instance"
  schedule_expression = "cron(<Insert the schedule here according to your needs to start the Instance>)"
}

#Lambda Permission for CloudWatch to Trigger Start EC2 Lambda
resource "aws_lambda_permission" "allow_cloudwatch_to_call_start_ec2" {
  statement_id  = "AllowExecutionFromCloudWatchStart"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.start_ec2_instance.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.start_ec2_schedule.arn
}