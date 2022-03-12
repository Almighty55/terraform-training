resource "aws_s3_bucket" "tf_state_bucket" {
  bucket = "alaraj-terraform-state1"
  #! THIS IS TRUE FOR TESTING
  force_destroy = true
  lifecycle {
    #! THIS IS FALSE FOR TESTING
    prevent_destroy = false
  }
}
resource "aws_s3_bucket_versioning" "versioning_tf_state" {
  bucket = aws_s3_bucket.tf_state_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption_tfstate" {
  bucket = aws_s3_bucket.tf_state_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
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