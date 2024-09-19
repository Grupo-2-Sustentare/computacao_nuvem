provider "aws" {
  region = "us-east-1" 
}

# 1. Criar a VPC
resource "aws_vpc" "vpc_main" {
  cidr_block = "10.0.0.0/25"  # Endereço CIDR da VPC
  enable_dns_support   = true  # Habilitar suporte a DNS
  enable_dns_hostnames = true  # Habilitar nomes DNS

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

# 5. Criar a Route Table
resource "aws_route_table" "main_route_table" {
  vpc_id = aws_vpc.vpc_main.id

  route {
    cidr_block = "0.0.0.0/0"           # Rota para todo o tráfego
    gateway_id = aws_internet_gateway.igw.id  # Usar o Internet Gateway
  }

  tags = {
    Name = "Main-Route-Table"
  }
}

# 6. Associar a Route Table com a Subnet Pública
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.main_route_table.id
}

# 7. Associar a Route Table com a Subnet Privada
resource "aws_route_table_association" "private_subnet_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.main_route_table.id
}

# 8. Criar Security Group para as instâncias EC2
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

# 9. Criar instância EC2 na Subnet Pública
resource "aws_instance" "frontend_instance" {
  ami                   = "ami-0e86e20dae9224db8"  # ID da AMI
  instance_type         = "t2.micro"              # Tipo da instância
  subnet_id             = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "Frontend-EC2-Instance"
  }
}

# 10. Criar instância EC2 na Subnet Privada
resource "aws_instance" "backend_instance" {
  ami                   = "ami-0e86e20dae9224db8"  # ID da AMI
  instance_type         = "t2.micro"              # Tipo da instância
  subnet_id             = aws_subnet.private_subnet.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "Backend-EC2-Instance"
  }
}
