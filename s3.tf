resource "aws_s3_bucket" "remote_state" {
  bucket = "levalves-terraform-tfstates"
}

resource "aws_s3_bucket_versioning" "remote_state" {
  bucket = aws_s3_bucket.remote_state.id
  versioning_configuration {
    status = "Enabled"
  }
}