# Criar Bucket S3
resource "aws_s3_bucket" "image_bucket" {
  bucket = var.s3_bucket_name

  tags = {
    Name = "ImageBucket"
  }
}

# Bloquear acessos públicos para o bucket S3
resource "aws_s3_bucket_public_access_block" "image_bucket_public_access" {
  bucket = aws_s3_bucket.image_bucket.id

  block_public_acls        = true
  block_public_policy      = true
  restrict_public_buckets  = true
  ignore_public_acls       = true
}

# Definir Política do Bucket S3
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.image_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = "*",
        Action = "s3:GetObject",
        Resource = "${aws_s3_bucket.image_bucket.arn}/*"
      }
    ]
  })
}
