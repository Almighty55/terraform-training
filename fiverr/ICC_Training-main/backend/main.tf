resource "aws_s3_bucket" "tfstate_bucket" {
  bucket = "ICC-training-terraform-state"
  lifecycle {
    prevent_destroy = true
  }
}
resource "aws_s3_bucket_versioning" "versioning_tfstate" {
  bucket = aws_s3_bucket.tfstate_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption_tfstate" {
  bucket = aws_s3_bucket.tfstate_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "block_public_tfstate" {
  bucket              = aws_s3_bucket.tfstate_bucket.id
  block_public_acls   = true
  block_public_policy = true
}