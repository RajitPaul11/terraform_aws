provider "aws" {
  region = "ap-south-1"
  profile = "default"
}

resource "aws_s3_bucket" "s3-bucket" {
  bucket = "s3lifecyclerulesbucket"
  acl    = "private"

  lifecycle_rule {
    enabled = true
    prefix  = "oldimg/"
    id = "lifecycle-rule"

    transition {
      storage_class = "ONEZONE_IA"
      days          = 30
    }

    transition {
      storage_class = "GLACIER"
      days          = 90
    }

    expiration {
      days = 365
    }
  }
  versioning {
      enabled = false
      mfa_delete = false
    }
}