resource "aws_dynamodb_table" "dynamodb" {
  name         = "Emails-staging"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "Email"

  attribute {
    name = "Email"
    type = "S"
  }

  tags = {
    Environment = "staging"
    Project     = "HN Ruby Digest"
    ManagedBy   = "Terraform"
  }

  # staging環境では柔軟に削除したいため、コメントアウト
  # lifecycle {
  #   prevent_destroy = true
  # }
}

# resource "aws_dynamodb_table_item" を使うとテスト用のseedデータが投入できる
# resource "aws_dynamodb_table_item" "dynamodb_item" {
#   table_name = aws_dynamodb_table.dynamodb.name
#   hash_key   = aws_dynamodb_table.dynamodb.hash_key

#   item = <<-EOT
#     {
#       "Email": { "S": "example@example.com" }
#     }
#   EOT
# }