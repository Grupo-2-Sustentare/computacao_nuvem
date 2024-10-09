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

# 11. Definir o Load Balancer
resource "aws_lb" "app_lb" {
  name               = "app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.public_sg.id]
  subnets            = [aws_subnet.public_subnet.id]

  tags = {
    Name = "App-Load-Balancer"
  }
}

# 12. Configurar o Listener para HTTP
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

# 13. Configurar o Listener para HTTPS
resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

# 14. Configurar o Target Group
resource "aws_lb_target_group" "app_tg" {
  name     = "app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc_main.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200"
  }

  tags = {
    Name = "App-Target-Group"
  }
}

# 15. Registrar as Instâncias no Target Group
resource "aws_lb_target_group_attachment" "frontend_instance" {
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = aws_instance.frontend_instance.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "backend_instance" {
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = aws_instance.backend_instance.id
  port             = 80
}