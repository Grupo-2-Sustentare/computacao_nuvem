# Variável para a região da AWS
variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

# Variável para o ARN do certificado SSL
variable "certificate_arn" {
  description = "ARN do certificado SSL para o Load Balancer"
  type        = string
}

# Variável para o tipo de instância EC2 pública
variable "public_instance_type" {
  description = "Tipo de instância EC2 para a instância pública"
  type        = string
  default     = "t2.micro"
}

# Variável para o tipo de instância EC2 privada
variable "private_instance_type" {
  description = "Tipo de instância EC2 para a instância privada"
  type        = string
  default     = "t2.micro"
}

# Variável para a chave SSH pública
variable "public_key_path" {
  description = "Caminho para a chave SSH pública"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

# Variável para o nome do bucket S3
variable "s3_bucket_name" {
  description = "Nome do bucket S3"
  type        = string
}

# Variável para o nome VPC
variable "vpc_name" {
  description = "Nome da VPC"
  type        = string
  default     = "Main-VPC"
}

# Variável para o CIDR da VPC
variable "vpc_cidr" {
  description = "CIDR da VPC"
  type        = string
  default     = "10.0.0.0/25"
}

# Variável para o CIDR da Subnet Pública
variable "public_subnet_cidr" {
  description = "CIDR da Subnet Pública"
  type        = string
  default     = "10.0.0.0/27"
}

# Variável para o CIDR da Subnet Privada
variable "private_subnet_cidr" {
  description = "CIDR da Subnet Privada"
  type        = string
  default     = "10.0.0.32/27"
}