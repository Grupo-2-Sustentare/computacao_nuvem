# 13. Criar bucket S3 para armazenamento de imagens
resource "aws_s3_bucket" "image_bucket" {
  bucket = var.s3_bucket_name

  tags = {
    Name = "Image-Storage"
  }
}

# 14. Desativar o Bloqueio de Políticas Públicas para o bucket S3
resource "aws_s3_bucket_public_access_block" "image_bucket_public_access" {
  bucket = aws_s3_bucket.image_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  restrict_public_buckets = false
  ignore_public_acls      = false
}

# 15. Definir Política de Bucket S3 para Permitir Upload, Acesso e Deleção Públicos
resource "aws_s3_bucket_policy" "image_bucket_policy" {
  bucket = aws_s3_bucket.image_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = "*",  # Permitir acesso para qualquer um
        Action    = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        Resource  = "${aws_s3_bucket.image_bucket.arn}/*"
      }
    ]
  })
}

# 16. Subir objeto de imagem para o bucket S3
resource "aws_s3_object" "example_image" {
  bucket = aws_s3_bucket.image_bucket.bucket
  key    = var.image_key  # Nome do objeto no S3
  source = var.image_source_path  # Caminho local para o arquivo

  tags = {
    Name = "Example-Image"
  }
}