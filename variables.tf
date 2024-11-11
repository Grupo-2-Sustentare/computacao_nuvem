# Variável para a região principal da AWS
variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

# Variável para a região secundária da AWS
variable "secondary_region" {
  description = "The secondary AWS region to deploy resources in"
  type        = string
  default     = "us-west-1"  # Exemplo de região secundária
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

# Variável para o Nome do Bucket S3
variable "s3_bucket_name" {
  description = "Nome do bucket S3"
  type        = string
  default     = "sustentare-bucket-test"
}

# Variável para o Nome da Política do Bucket S3
variable "s3_bucket_policy_name" {
  description = "Nome da política de bucket S3"
  type        = string
  default     = "sustentare-image-bucket-policy"
}

# Variável para o Nome do Bloqueio de Acesso Público
variable "s3_public_access_block_name" {
  description = "Nome da configuração de bloqueio de acesso público do S3"
  type        = string
  default     = "sustentare-public-access-block"
}

# Variável para o nome da VPC
variable "vpc_name" {
  description = "Nome da VPC"
  type        = string
  default     = "Main-VPC-test"
}

# Variável para o CIDR da VPC
variable "vpc_cidr" {
  description = "CIDR da VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# Variáveis para os CIDRs das Subnets Públicas
variable "public_subnet_a_cidr" {
  description = "CIDR da Subnet Pública na AZ A"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_b_cidr" {
  description = "CIDR da Subnet Pública na AZ B"
  type        = string
  default     = "10.0.2.0/24"
}

# Variáveis para os CIDRs das Subnets Privadas
variable "private_subnet_a_cidr" {
  description = "CIDR da Subnet Privada na AZ A"
  type        = string
  default     = "10.0.3.0/24"
}

variable "private_subnet_b_cidr" {
  description = "CIDR da Subnet Privada na AZ B"
  type        = string
  default     = "10.0.4.0/24"
}

# Variável para o ID da AMI
variable "ami_id" {
  description = "AMI ID para instâncias"
  type        = string
  default     = "ami-0e86e20dae9224db8" # Substitua pelo ID específico que deseja usar
}

# Variável para o nome do Security Group Público
variable "public_sg_name" {
  description = "Nome para o Security Group Público"
  type        = string
  default     = "Public-Security-Group"
}

# Variável para o nome do Security Group Privado
variable "private_sg_name" {
  description = "Nome para o Security Group Privado"
  type        = string
  default     = "Private-Security-Group"
}

# Variável para o caminho do arquivo de imagem
variable "image_source_path" {
  description = "Caminho local para o arquivo de imagem"
  type        = string
  default     = "the.jpeg"
}

# Variável para a chave do objeto no S3
variable "image_key" {
  description = "Nome do objeto no S3"
  type        = string
  default     = "the.jpeg"
}