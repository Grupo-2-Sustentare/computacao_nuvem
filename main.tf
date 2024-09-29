provider "aws" {
  region = "us-east-1"  # Define a região da AWS
}

# 1. Criar a VPC
resource "aws_vpc" "vpc_main" {
  cidr_block           = "10.0.0.0/25"  # Endereço CIDR da VPC
  enable_dns_support   = true           # Habilitar suporte a DNS
  enable_dns_hostnames = true           # Habilitar nomes DNS

  tags = {
    Name = "Main-VPC"  # Nome da VPC
  }
}

# 2. Criar Subnet Pública
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc_main.id  # Referência à VPC
  cidr_block              = "10.0.0.0/27"        # Endereço CIDR da Sub-rede Pública
  map_public_ip_on_launch = true                 # Atribuir IPs públicos automaticamente
  availability_zone       = "us-east-1a"         # Zona de disponibilidade

  tags = {
    Name = "Public-Subnet"  # Nome da Sub-rede Pública
  }
}

# 3. Criar Subnet Privada
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.vpc_main.id  # Referência à VPC
  cidr_block        = "10.0.0.32/27"        # Endereço CIDR da Sub-rede Privada
  availability_zone = "us-east-1a"          # Zona de disponibilidade

  tags = {
    Name = "Private-Subnet"  # Nome da Sub-rede Privada
  }
}

# 4. Criar Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_main.id  # Referência à VPC

  tags = {
    Name = "Main-Internet-Gateway"  # Nome do Internet Gateway
  }
}

# 5. Criar NAT Gateway para a Subnet Privada
resource "aws_eip" "nat_eip" {
  # Cria um Elastic IP para o NAT Gateway
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id  # Referência ao Elastic IP
  subnet_id     = aws_subnet.public_subnet.id  # Referência à Sub-rede Pública

  tags = {
    Name = "Main-NAT-Gateway"  # Nome do NAT Gateway
  }
}

# 6. Criar a Route Table para a Subnet Pública
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc_main.id  # Referência à VPC

  route {
    cidr_block = "0.0.0.0/0"                  # Rota para todo o tráfego
    gateway_id = aws_internet_gateway.igw.id  # Usar o Internet Gateway
  }

  tags = {
    Name = "Public-Route-Table"  # Nome da Route Table Pública
  }
}

# 7. Associar a Route Table com a Subnet Pública
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id  # Referência à Sub-rede Pública
  route_table_id = aws_route_table.public_route_table.id  # Referência à Route Table Pública
}

# 8. Criar uma Route Table para a Subnet Privada
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc_main.id  # Referência à VPC

  route {
    cidr_block = "0.0.0.0/0"                  # Rota para todo o tráfego
    gateway_id = aws_nat_gateway.nat_gw.id    # Usar o NAT Gateway
  }

  tags = {
    Name = "Private-Route-Table"  # Nome da Route Table Privada
  }
}

# 9. Associar a Route Table com a Subnet Privada
resource "aws_route_table_association" "private_subnet_association" {
  subnet_id      = aws_subnet.private_subnet.id  # Referência à Sub-rede Privada
  route_table_id = aws_route_table.private_route_table.id  # Referência à Route Table Privada
}

# 10. Criar Security Group para as instâncias EC2
resource "aws_security_group" "web_sg" {
  vpc_id = aws_vpc.vpc_main.id  # Referência à VPC

  ingress {
    from_port   = 80              # Permitir tráfego HTTP
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]   # Permitir tráfego HTTP de qualquer IP
  }

  ingress {
    from_port   = 443             # Permitir tráfego HTTPS
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]   # Permitir tráfego HTTPS de qualquer IP
  }

  egress {
    from_port   = 0                # Permitir todo o tráfego de saída
    to_port     = 0
    protocol    = "-1"             # Todos os protocolos
    cidr_blocks = ["0.0.0.0/0"]    # Permitir todo o tráfego de saída
  }

  tags = {
    Name = "Web-Security-Group"  # Nome do Security Group
  }
}

# 11. Criar instância EC2 na Subnet Pública com Volume EBS
resource "aws_instance" "frontend_instance" {
  ami                    = "ami-0e86e20dae9224db8"  # ID da AMI
  instance_type          = "t2.micro"              # Tipo da instância
  subnet_id              = aws_subnet.public_subnet.id  # Referência à Sub-rede Pública
  vpc_security_group_ids = [aws_security_group.web_sg.id]  # Referência ao Security Group

  # Volume SSD de 5 GiB
  root_block_device {
    volume_type = "gp3"  # Tipo de volume SSD
    volume_size = 5      # Tamanho do volume em GiB
  }

  tags = {
    Name = "Frontend-EC2-Instance"  # Nome da instância EC2 Frontend
  }
}

# 12. Criar instância EC2 na Subnet Privada
resource "aws_instance" "backend_instance" {
  ami                    = "ami-0e86e20dae9224db8"  # ID da AMI
  instance_type          = "t2.micro"              # Tipo da instância
  subnet_id              = aws_subnet.private_subnet.id  # Referência à Sub-rede Privada
  vpc_security_group_ids = [aws_security_group.web_sg.id]  # Referência ao Security Group

  tags = {
    Name = "Backend-EC2-Instance"  # Nome da instância EC2 Backend
  }
}

# 13. Criar bucket S3 para armazenamento de imagens
resource "aws_s3_bucket" "image_bucket" {
  bucket = "sustentare-s3-exemple"  # Nome do bucket S3

  tags = {
    Name = "Image-Storage"  # Nome do bucket S3
  }
}

# 14. Bloquear acessos públicos para o bucket S3
resource "aws_s3_bucket_public_access_block" "image_bucket_public_access" {
  bucket = aws_s3_bucket.image_bucket.id  # Referência ao bucket S3

  block_public_acls        = true  # Bloquear ACLs públicas
  block_public_policy      = true  # Bloquear políticas públicas
  restrict_public_buckets  = true  # Restringir acesso público ao bucket
  ignore_public_acls       = true  # Ignorar ACLs públicas
}

# 15. Definir política de bucket S3 para permitir upload privado
resource "aws_s3_bucket_policy" "image_bucket_policy" {
  bucket = aws_s3_bucket.image_bucket.id  # Referência ao bucket S3

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",                # Permitir ações
        Principal = "*",                     # Principal permite todos
        Action    = [
          "s3:GetObject",                   # Permitir obter objetos
          "s3:PutObject"                    # Permitir subir objetos
        ],
        Resource  = "${aws_s3_bucket.image_bucket.arn}/*"  # Referência aos recursos do bucket
      }
    ]
  })
}

# 16. Subir objeto de imagem para o bucket S3
resource "aws_s3_object" "example_image" {
  bucket = aws_s3_bucket.image_bucket.bucket  # Referência ao bucket S3
  key    = "the.jpeg"  # Nome do objeto no S3
  source = ""  # Caminho local para o arquivo (definir o caminho do arquivo)

  acl = "private"  # Definir como privado

  tags = {
    Name = "Example-Image"  # Nome do objeto no S3
  }
}

# ACL para Sub-rede Pública
resource "aws_network_acl" "public_acl" {
  vpc_id = aws_vpc.vpc_main.id  # Referência à VPC

  tags = {
    Name = "Public-ACL"  # Nome da ACL Pública
  }
}

# Regras da ACL para Sub-rede Pública
resource "aws_network_acl_rule" "http_inbound" {
  network_acl_id = aws_network_acl.public_acl.id  # Referência à ACL Pública
  rule_number    = 100  # Número da regra
  egress         = false  # Ingress (entrada)
  protocol       = "tcp"  # Protocolo TCP
  rule_action    = "allow" # Ação: permitir
  cidr_block     = "0.0.0.0/0"  # Permitir de qualquer origem
  from_port      = 80  # Porta de origem
  to_port        = 80  # Porta de destino
}

resource "aws_network_acl_rule" "https_inbound" {
  network_acl_id = aws_network_acl.public_acl.id  # Referência à ACL Pública
  rule_number    = 110  # Número da regra
  egress         = false  # Ingress (entrada)
  protocol       = "tcp"  # Protocolo TCP
  rule_action    = "allow" # Ação: permitir
  cidr_block     = "0.0.0.0/0"  # Permitir de qualquer origem
  from_port      = 443  # Porta de origem
  to_port        = 443  # Porta de destino
}

resource "aws_network_acl_rule" "outbound_allow" {
  network_acl_id = aws_network_acl.public_acl.id  # Referência à ACL Pública
  rule_number    = 200  # Número da regra
  egress         = true  # Egress (saída)
  protocol       = "-1"  # Todos os protocolos
  rule_action    = "allow" # Ação: permitir
  cidr_block     = "0.0.0.0/0"  # Permitir para qualquer destino
}

# ACL para Sub-rede Privada
resource "aws_network_acl" "private_acl" {
  vpc_id = aws_vpc.vpc_main.id  # Referência à VPC

  tags = {
    Name = "Private-ACL"  # Nome da ACL Privada
  }
}

# Regras da ACL para Sub-rede Privada
resource "aws_network_acl_rule" "private_inbound" {
  network_acl_id = aws_network_acl.private_acl.id  # Referência à ACL Privada
  rule_number    = 100  # Número da regra
  egress         = false  # Ingress (entrada)
  protocol       = "tcp"  # Protocolo TCP
  rule_action    = "allow" # Ação: permitir
  cidr_block     = "0.0.0.0/0"  # Permitir de qualquer origem (trocar para IP da Sub-rede Pública se necessário)
  from_port      = 0  # Porta de origem
  to_port        = 65535  # Porta de destino
}

resource "aws_network_acl_rule" "private_outbound" {
  network_acl_id = aws_network_acl.private_acl.id  # Referência à ACL Privada
  rule_number    = 200  # Número da regra
  egress         = true  # Egress (saída)
  protocol       = "-1"  # Todos os protocolos
  rule_action    = "allow" # Ação: permitir
  cidr_block     = "0.0.0.0/0"  # Permitir para qualquer destino
}
