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

output "frontend_instance_ids" {
  description = "IDs das Instâncias EC2 Públicas"
  value       = aws_autoscaling_group.frontend_asg.instances
}

output "backend_instance_ids" {
  description = "IDs das Instâncias EC2 Privadas"
  value       = aws_autoscaling_group.backend_asg.instances
}

output "s3_bucket_name" {
  description = "Nome do Bucket S3"
  value       = aws_s3_bucket.image_bucket.bucket
}

output "load_balancer_dns" {
  description = "DNS do Load Balancer"
  value       = aws_lb.app_lb.dns_name
}