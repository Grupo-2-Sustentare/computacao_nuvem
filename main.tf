provider "aws" {
  region = "us-east-1"
}

# 1. Criar a VPC
resource "aws_vpc" "vpc_main" {
  cidr_block           = "10.0.0.0/25"  # Endereço CIDR da VPC
  enable_dns_support   = true           # Habilitar suporte a DNS
  enable_dns_hostnames = true           # Habilitar nomes DNS

  tags = {
    Name = "Main-VPC"
  }
}

# 2. Criar Subnet Pública
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc_main.id
  cidr_block              = "10.0.0.0/27"  # Sub-rede pública
  map_public_ip_on_launch = true           # Atribuir IPs públicos automaticamente
  availability_zone       = "us-east-1a"   # Zona de disponibilidade

  tags = {
    Name = "Public-Subnet"
  }
}

# 3. Criar Subnet Privada
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.vpc_main.id
  cidr_block        = "10.0.0.32/27"  # Sub-rede privada
  availability_zone = "us-east-1b"    # Zona de disponibilidade diferente

  tags = {
    Name = "Private-Subnet"
  }
}

# 4. Criar Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_main.id

  tags = {
    Name = "Main-Internet-Gateway"
  }
}

# 5. Criar NAT Gateway para a Subnet Privada
resource "aws_eip" "nat_eip" {
  tags = {
    Name = "NAT-EIP"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name = "Main-NAT-Gateway"
  }
}

# 6. Criar a Route Table para a Subnet Pública
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc_main.id

  route {
    cidr_block = "0.0.0.0/0"                # Rota para todo o tráfego
    gateway_id = aws_internet_gateway.igw.id  # Usar o Internet Gateway
  }

  tags = {
    Name = "Public-Route-Table"
  }
}

# 7. Associar a Route Table com a Subnet Pública
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# 8. Criar uma Route Table para a Subnet Privada
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc_main.id

  route {
    cidr_block = "0.0.0.0/0"                # Rota para todo o tráfego
    gateway_id = aws_nat_gateway.nat_gw.id   # Usar o NAT Gateway
  }

  tags = {
    Name = "Private-Route-Table"
  }
}

# 9. Associar a Route Table com a Subnet Privada
resource "aws_route_table_association" "private_subnet_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}

# 10. Criar Security Group para as instâncias EC2
resource "aws_security_group" "web_sg" {
  vpc_id = aws_vpc.vpc_main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Permitir tráfego HTTP de qualquer IP
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Permitir tráfego HTTPS de qualquer IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Permitir todo o tráfego de saída
  }

  tags = {
    Name = "Web-Security-Group"
  }
}

# 11. Criar instância EC2 na Subnet Pública com Volume EBS
resource "aws_instance" "frontend_instance" {
  ami                    = "ami-0e86e20dae9224db8"  # ID da AMI
  instance_type          = "t2.micro"              # Tipo da instância
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  # Volume SSD de 8 GiB
  root_block_device {
    volume_type = "gp3"  # Tipo de volume SSD
    volume_size = 8      # Tamanho do volume em GiB
  }

  # Script de inicialização para montar o EFS
  user_data = <<-EOF
              #!/bin/bash
              yum install -y amazon-efs-utils
              mkdir /mnt/efs
              mount -t efs ${aws_efs_file_system.example.id}:/ /mnt/efs
              EOF

  tags = {
    Name = "Frontend-EC2-Instance"
  }
}

# 12. Criar instância EC2 na Subnet Privada
resource "aws_instance" "backend_instance" {
  ami                    = "ami-0e86e20dae9224db8"  # ID da AMI
  instance_type          = "t2.micro"              # Tipo da instância
  subnet_id              = aws_subnet.private_subnet.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  # Script de inicialização para montar o EFS
  user_data = <<-EOF
              #!/bin/bash
              yum install -y amazon-efs-utils
              mkdir /mnt/efs
              mount -t efs ${aws_efs_file_system.example.id}:/ /mnt/efs
              EOF

  tags = {
    Name = "Backend-EC2-Instance"
  }
}

# 13. Criar bucket S3 para armazenamento de imagens
resource "aws_s3_bucket" "image_bucket" {
  bucket = "sustentare-s3-example"  # Nome do bucket S deve ser único globalmente

  tags = {
    Name = "Image-Storage"
  }
}

# 14. Permitir acessos públicos para o bucket S3
resource "aws_s3_bucket_public_access_block" "image_bucket_public_access" {
  bucket = aws_s3_bucket.image_bucket.id

  block_public_acls        = false  # Permitir ACLs públicas
  block_public_policy      = false  # Permitir políticas públicas
  restrict_public_buckets  = false  # Permitir buckets públicos
  ignore_public_acls       = false  # Não ignorar ACLs públicas
}

# 15. Definir política de bucket S3 para permitir upload privado
resource "aws_s3_bucket_policy" "image_bucket_policy" {
  bucket = aws_s3_bucket.image_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = "*",
        Action    = [
          "s3:GetObject",
          "s3:PutObject"
        ],
        Resource  = "${aws_s3_bucket.image_bucket.arn}/*"
      }
    ]
  })
}

# 16. Subir objeto de imagem para o bucket S3
resource "aws_s3_object" "example_image" {
  bucket = aws_s3_bucket.image_bucket.bucket
  key    = "the.jpeg"  # Nome do objeto no S3
  source = "C:\\Users\\steph\\OneDrive\\Área de Trabalho\\Faculdade\\computacao_nuvem\\the.jpeg"  # Caminho local para o arquivo

  acl = "private"  # Definir como privado

  tags = {
    Name = "Example-Image"
  }
}

# 17. Criar Sistema de Arquivos EFS
resource "aws_efs_file_system" "example" {
  encrypted = true  # Criptografar o sistema de arquivos

  tags = {
    Name = "Main-EFS"
  }
}

# 18. Criar Mount Targets para o EFS
resource "aws_efs_mount_target" "public_mount_target" {
  file_system_id  = aws_efs_file_system.example.id
  subnet_id       = aws_subnet.public_subnet.id
  security_groups = [aws_security_group.web_sg.id]

  lifecycle {
    prevent_destroy = false  # Permitir destruição do recurso
  }
}

resource "aws_efs_mount_target" "private_mount_target" {
  file_system_id  = aws_efs_file_system.example.id
  subnet_id       = aws_subnet.private_subnet.id
  security_groups = [aws_security_group.web_sg.id]

  lifecycle {
    prevent_destroy = false  # Permitir destruição do recurso
  }
}

# 19. Regras para permitir NFS (porta 2049)
resource "aws_security_group_rule" "allow_efs_nfs" {
  type              = "ingress"
  from_port         = 2049
  to_port           = 2049
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web_sg.id
}

# ACL para Sub-rede Pública
resource "aws_network_acl" "public_acl" {
  vpc_id = aws_vpc.vpc_main.id

  tags = {
    Name = "Public-ACL"
  }
}

# Regras da ACL para Sub-rede Pública
resource "aws_network_acl_rule" "http_inbound" {
  network_acl_id = aws_network_acl.public_acl.id
  rule_number    = 100
  egress         = false  # Ingress (entrada)
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"  # Permitir de qualquer origem
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "https_inbound" {
  network_acl_id = aws_network_acl.public_acl.id
  rule_number    = 110
  egress         = false  # Ingress (entrada)
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"  # Permitir de qualquer origem
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "ephemeral_outbound" {
  network_acl_id = aws_network_acl.public_acl.id
  rule_number    = 100
  egress         = true  # Egress (saída)
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"  # Permitir para qualquer destino
  from_port      = 1024
  to_port        = 65535
}