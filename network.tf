# 1. Criar a VPC
resource "aws_vpc" "vpc_main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_name
  }
}

# 2. Criar Subnets Públicas em múltiplas AZs
resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = aws_vpc.vpc_main.id
  cidr_block              = var.public_subnet_a_cidr
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zones[0]

  tags = {
    Name = "Public-Subnet-A"
  }
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id                  = aws_vpc.vpc_main.id
  cidr_block              = var.public_subnet_b_cidr
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zones[1]

  tags = {
    Name = "Public-Subnet-B"
  }
}

# 3. Criar Subnets Privadas em múltiplas AZs
resource "aws_subnet" "private_subnet_a" {
  vpc_id            = aws_vpc.vpc_main.id
  cidr_block        = var.private_subnet_a_cidr
  availability_zone = var.availability_zones[0]

  tags = {
    Name = "Private-Subnet-A"
  }
}

resource "aws_subnet" "private_subnet_b" {
  vpc_id            = aws_vpc.vpc_main.id
  cidr_block        = var.private_subnet_b_cidr
  availability_zone = var.availability_zones[1]

  tags = {
    Name = "Private-Subnet-B"
  }
}

# 4. Criar Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_main.id

  tags = {
    Name = "Main-Internet-Gateway"
  }
}

# 5. Criar a Route Table para as Subnets Públicas
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc_main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Public-Route-Table"
  }
}

# Atualizar Route Table das Subnets Públicas
resource "aws_route_table_association" "public_subnet_association_a" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_association_b" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_route_table.id
}

# 7. Criar uma Route Table para as Subnets Privadas
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc_main.id

  tags = {
    Name = "Private-Route-Table"
  }
}

# 8. Associar a Route Table com as Subnets Privadas
resource "aws_route_table_association" "private_subnet_association_a" {
  subnet_id      = aws_subnet.private_subnet_a.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_subnet_association_b" {
  subnet_id      = aws_subnet.private_subnet_b.id
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
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3006
    to_port     = 3006
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.public_sg_name
  }
}

# 10. Criar Security Group Privado
resource "aws_security_group" "private_sg" {
  vpc_id = aws_vpc.vpc_main.id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.private_sg_name
  }
}

# 11. Definir o Load Balancer
resource "aws_lb" "app_lb" {
  name               = "app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.public_sg.id]
  subnets            = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]

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
    target_group_arn = aws_lb_target_group.app_tg_a.arn
  }
}

# 13. Configurar o Target Group para a Zona de Disponibilidade A
resource "aws_lb_target_group" "app_tg_a" {
  name     = "app-tg-a"
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
    Name = "App-Target-Group-A"
  }
}

# 14. Configurar o Target Group para a Zona de Disponibilidade B
resource "aws_lb_target_group" "app_tg_b" {
  name     = "app-tg-b"
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
    Name = "App-Target-Group-B"
  }
}

# 15. Associar o Auto Scaling Group ao Target Group A
resource "aws_autoscaling_attachment" "frontend_asg_attachment_a" {
  autoscaling_group_name = aws_autoscaling_group.frontend_asg.name
  lb_target_group_arn    = aws_lb_target_group.app_tg_a.arn
}

# 16. Associar o Auto Scaling Group ao Target Group B
resource "aws_autoscaling_attachment" "frontend_asg_attachment_b" {
  autoscaling_group_name = aws_autoscaling_group.frontend_asg.name
  lb_target_group_arn    = aws_lb_target_group.app_tg_b.arn
}

# Criar Elastic IP para o NAT Gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name = "NAT-Gateway-EIP"
  }
}

# Criar NAT Gateway
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet_a.id

  tags = {
    Name = "NAT-Gateway"
  }
}

# Atualizar Route Table das Subnets Privadas para usar o NAT Gateway
resource "aws_route" "private_route" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway.id
}

# Criar ACL (Access Control List) para as Subnets Públicas
resource "aws_network_acl" "public_acl" {
  vpc_id = aws_vpc.vpc_main.id

  ingress {
    rule_no    = 100
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  ingress {
    rule_no    = 110
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  ingress {
    rule_no    = 120
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }

  ingress {
    rule_no    = 130
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 25565
    to_port    = 25565
  }

  ingress {
    rule_no    = 140
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 3006
    to_port    = 3006
  }

  ingress {
    rule_no    = 90
    protocol   = "-1" # Todos os protocolos
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    rule_no    = 150
    protocol   = "-1"     # All traffic
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "Public-ACL"
  }
}

# Associar ACL às Subnets Públicas
resource "aws_network_acl_association" "public_acl_association_a" {
  subnet_id      = aws_subnet.public_subnet_a.id
  network_acl_id = aws_network_acl.public_acl.id
}

resource "aws_network_acl_association" "public_acl_association_b" {
  subnet_id      = aws_subnet.public_subnet_b.id
  network_acl_id = aws_network_acl.public_acl.id
}

# Criar ACL (Access Control List) para as Subnets Privadas
resource "aws_network_acl" "private_acl" {
  vpc_id = aws_vpc.vpc_main.id

  egress {
    rule_no    = 100
    protocol   = "-1"     # All traffic
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "Private-ACL"
  }
}

# Associar ACL às Subnets Privadas
resource "aws_network_acl_association" "private_acl_association_a" {
  subnet_id      = aws_subnet.private_subnet_a.id
  network_acl_id = aws_network_acl.private_acl.id
}

resource "aws_network_acl_association" "private_acl_association_b" {
  subnet_id      = aws_subnet.private_subnet_b.id
  network_acl_id = aws_network_acl.private_acl.id
}