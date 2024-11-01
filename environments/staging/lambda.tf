data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda_staging"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "../../applications/lambda_function.rb"
  output_path = "${path.module}/../../applications/lambda_function_payload.zip"
}

resource "aws_lambda_function" "hn_ruby" {
  filename      = data.archive_file.lambda.output_path
  function_name = "hn_ruby_staging"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda_function.lambda_handler"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "ruby3.3"

  environment {
    variables = {
      ENV = "staging"
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.hn_ruby,
  ]

  timeout = 15
}

resource "aws_cloudwatch_log_group" "hn_ruby" {
  name              = "/aws/lambda/hn_ruby_staging"
  retention_in_days = 14
}

data "aws_iam_policy_document" "lambda_logging" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["arn:aws:logs:*:*:*"]
  }
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging_staging"
  path        = "/"
  description = "IAM policy for logging from a lambda"
  policy      = data.aws_iam_policy_document.lambda_logging.json
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

# DynamoDBへのアクセスを許可するポリシードキュメント
data "aws_iam_policy_document" "dynamodb_access" {
  statement {
    effect = "Allow"

    actions = [
      "dynamodb:Scan",
    ]

    resources = [
      aws_dynamodb_table.users.arn,
      "${aws_dynamodb_table.users.arn}/index/EmailIndex"
    ]
  }
}

# DynamoDBアクセス用のIAMポリシー
resource "aws_iam_policy" "dynamodb_access_policy" {
  name        = "dynamodb_access_policy_staging"
  path        = "/"
  description = "IAM policy to allow DynamoDB Scan on Users-staging table"
  policy      = data.aws_iam_policy_document.dynamodb_access.json
}

# DynamoDBアクセス用のポリシーをIAMロールにアタッチ
resource "aws_iam_role_policy_attachment" "dynamodb_access_attachment" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.dynamodb_access_policy.arn
}
