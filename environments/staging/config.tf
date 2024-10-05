terraform {
  required_version = "1.9.7"

  # TODO: バックエンドを設定する
  # backend "s3" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.70.0"
    }
  }
}

provider "aws" {
  region  = "ap-northeast-1"
  profile = "hn-ruby"
}