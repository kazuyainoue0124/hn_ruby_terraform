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
}
