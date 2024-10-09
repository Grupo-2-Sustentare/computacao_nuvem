output "vpc_id" {
  description = "ID da VPC"
  value       = aws_vpc.vpc_main.id
}

output "public_subnet_id" {
  description = "ID da Sub-rede Pública"
  value       = aws_subnet.public_subnet.id
}

output "private_subnet_id" {
  description = "ID da Sub-rede Privada"
  value       = aws_subnet.private_subnet.id
}

output "frontend_instance_id" {
  description = "ID da Instância EC2 Pública"
  value       = aws_instance.frontend_instance.id
}

output "backend_instance_id" {
  description = "ID da Instância EC2 Privada"
  value       = aws_instance.backend_instance.id
}

output "s3_bucket_name" {
  description = "Nome do Bucket S3"
  value       = aws_s3_bucket.image_bucket.bucket
}

output "load_balancer_dns" {
  description = "DNS do Load Balancer"
  value       = aws_lb.app_lb.dns_name
}