terraform {
  backend "s3" {
    bucket = "dubiza-tf-state"
    key = "global/s3/terraform.tfstate"
    region = "us-east-1"

    dynamodb_table = "dubiza_tf_locks"
    encrypt = true
  }
}

provider "aws" {
  region = "us-east-1"
  profile = "terraform"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "dubiza-tf-state"

  lifecycle {
    prevent_destroy = true
  }

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name = "dubiza_tf_locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
