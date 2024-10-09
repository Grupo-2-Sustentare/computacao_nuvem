# 1. Criar a VPC
resource "aws_vpc" "vpc_main" {
  cidr_block           = var.vpc_cidr  # Endereço CIDR da VPC
  enable_dns_support   = true           # Habilitar suporte a DNS
  enable_dns_hostnames = true           # Habilitar nomes DNS

  tags = {
    Name = var.vpc_name
  }
}

# 2. Criar Subnet Pública
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc_main.id
  cidr_block              = var.public_subnet_cidr  # Sub-rede pública
  map_public_ip_on_launch = true           # Atribuir IPs públicos automaticamente
  availability_zone       = "us-east-1a"   # Zona de disponibilidade

  tags = {
    Name = "Public-Subnet"
  }
}

# 3. Criar Subnet Privada
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.vpc_main.id
  cidr_block        = var.private_subnet_cidr  # Sub-rede privada
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

# 5. Criar a Route Table para a Subnet Pública
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

# 6. Associar a Route Table com a Subnet Pública
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# 7. Criar uma Route Table para a Subnet Privada
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc_main.id

  tags = {
    Name = "Private-Route-Table"
  }
}

# 8. Associar a Route Table com a Subnet Privada
resource "aws_route_table_association" "private_subnet_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}

# 9. Criar Security Group Público
resource "aws_security_group" "public_sg" {
  vpc_id = aws_vpc.vpc_main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Permitir SSH de qualquer lugar
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Public-Security-Group"
  }
}

# 10. Criar Security Group Privado
resource "aws_security_group" "private_sg" {
  vpc_id = aws_vpc.vpc_main.id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]  # Permitir tráfego interno na VPC
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Private-Security-Group"
  }
}