variable "seed_emails" {
  description = "DynamoDBテーブルに挿入するメールアドレスのリスト"
  type        = list(string)
  sensitive   = true
}
