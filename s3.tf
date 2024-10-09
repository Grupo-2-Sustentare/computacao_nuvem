# Criar Bucket S3
resource "aws_s3_bucket" "image_bucket" {
  bucket = var.s3_bucket_name

  tags = {
    Name = "ImageBucket"
  }
}

# Definir Política do Bucket S3
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.image_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = "s3:GetObject"
        Resource = "${aws_s3_bucket.image_bucket.arn}/*"
      }
    ]
  })
}