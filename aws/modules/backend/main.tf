data "aws_s3_bucket" "tfstate" {
  bucket = "alaraj-terraform-state"
}

resource "aws_s3_bucket_versioning" "versioning_tfstate" {
  bucket = data.aws_s3_bucket.tfstate.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption_tfstate" {
  bucket = data.aws_s3_bucket.tfstate.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "block_public_tfstate" {
  bucket                  = data.aws_s3_bucket.tfstate.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#* useful if multiple people are working on the same codebase
# resource "aws_dynamodb_table" "lock_tfstate" {
#   name         = "terraform-state-locking"
#   billing_mode = "PAY_PER_REQUEST"
#   hash_key     = "LockID"

#   attribute {
#     name = "LockID"
#     type = "S"
#   }
# }