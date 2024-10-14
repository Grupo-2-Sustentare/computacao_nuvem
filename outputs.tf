output "vpc_id" {
  description = "ID da VPC"
  value       = aws_vpc.vpc_main.id
}

output "public_subnet_id_a" {
  description = "ID da Sub-rede Pública A"
  value       = aws_subnet.public_subnet_a.id
}

output "public_subnet_id_b" {
  description = "ID da Sub-rede Pública B"
  value       = aws_subnet.public_subnet_b.id
}

output "private_subnet_id_a" {
  description = "ID da Sub-rede Privada A"
  value       = aws_subnet.private_subnet_a.id
}

output "private_subnet_id_b" {
  description = "ID da Sub-rede Privada B"
  value       = aws_subnet.private_subnet_b.id
}

output "frontend_asg_id" {
  description = "ID do Auto Scaling Group das Instâncias EC2 Públicas"
  value       = aws_autoscaling_group.frontend_asg.id
}

output "backend_asg_id" {
  description = "ID do Auto Scaling Group das Instâncias EC2 Privadas"
  value       = aws_autoscaling_group.backend_asg.id
}

output "s3_bucket_name" {
  description = "Nome do Bucket S3"
  value       = aws_s3_bucket.image_bucket.bucket
}