resource "aws_dynamodb_table" "users" {
  name         = "Users-staging"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "UserId"

  attribute {
    name = "UserId"
    type = "S"
  }

  attribute {
    name = "Email"
    type = "S"
  }

  global_secondary_index {
    name            = "EmailIndex"
    hash_key        = "Email"
    projection_type = "ALL"
  }

  tags = {
    Environment = "staging"
    Project     = "HN Ruby"
    ManagedBy   = "Terraform"
  }

  # staging環境では柔軟に削除したいため、コメントアウト
  # lifecycle {
  #   prevent_destroy = true
  # }
}

# resource "aws_dynamodb_table_item" を使うとテスト用のseedデータが投入できる
resource "aws_dynamodb_table_item" "seed_email_items" {
  count = length(var.seed_emails)

  table_name = aws_dynamodb_table.users.name
  hash_key   = aws_dynamodb_table.users.hash_key

  item = jsonencode({
    UserId = { "S" = uuid() }
    Email  = { "S" = var.seed_emails[count.index] }
  })
}