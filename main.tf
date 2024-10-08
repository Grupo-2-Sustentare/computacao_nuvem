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
  availability_zone = "us-east-1a"    # Zona de disponibilidade

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
  # Cria um Elastic IP para o NAT Gateway
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

# 11. Criar instância EC2 na Subnet Pública
resource "aws_instance" "frontend_instance" {
  ami                    = "ami-0e86e20dae9224db8"  # ID da AMI
  instance_type          = "t2.micro"              # Tipo da instância
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]

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

  tags = {
    Name = "Backend-EC2-Instance"
  }
}

# 13. Criar bucket S3 para armazenamento de imagens
resource "aws_s3_bucket" "image_bucket" {
  bucket = "sustentare-s3"

  tags = {
    Name = "Image-Storage"
  }
}

# 14. Bloquear acessos públicos para o bucket S3
resource "aws_s3_bucket_public_access_block" "image_bucket_public_access" {
  bucket = aws_s3_bucket.image_bucket.id

  block_public_acls        = true
  block_public_policy      = true
  restrict_public_buckets  = true
  ignore_public_acls       = true
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
  source = "C:\\Users\\steph\\OneDrive\\Área de Trabalho\\Faculdade\\Sustentare\\the.jpeg"  # Caminho local para o arquivo

  acl = "private"  # Definir como privado

  tags = {
    Name = "Example-Image"
  }
}
