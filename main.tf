resource "aws_s3_bucket" "buckets" {
  for_each = toset(var.bucket_names)

  bucket = each.value
  acl    = "private"
  force_destroy = true

  tags = {
    name        = each.value
    student_id  = var.student_id
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

resource "aws_s3_bucket_public_access_block" "public_block" {
  for_each = toset(var.bucket_names)

  bucket = aws_s3_bucket.buckets[each.key].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "upload_file" {
  for_each     = toset(var.bucket_names)

  bucket       = aws_s3_bucket.buckets[each.key].id
  key          = basename(var.file_path)
  source       = var.file_path
  etag         = filemd5(var.file_path)
  content_type = "text/plain"
}
