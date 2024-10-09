# 12. Gerar chaves SSH
resource "tls_private_key" "public_instance_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_private_key" "private_instance_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "local_file" "public_instance_key_pem" {
  content  = tls_private_key.public_instance_key.private_key_pem
  filename = "${path.module}/public_instance_key.pem"
}

resource "local_file" "private_instance_key_pem" {
  content  = tls_private_key.private_instance_key.private_key_pem
  filename = "${path.module}/private_instance_key.pem"
}

resource "aws_key_pair" "public_instance_key" {
  key_name   = "public_instance_key"
  public_key = tls_private_key.public_instance_key.public_key_openssh
}

resource "aws_key_pair" "private_instance_key" {
  key_name   = "private_instance_key"
  public_key = tls_private_key.private_instance_key.public_key_openssh
}

# 13. Criar instância EC2 na Subnet Pública com Volume EBS
resource "aws_instance" "frontend_instance" {
  ami                    = "ami-0e86e20dae9224db8"  # ID da AMI
  instance_type          = "t2.micro"              # Tipo da instância
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.public_sg.id]
  key_name               = aws_key_pair.public_instance_key.key_name

  # Volume SSD de 8 GiB
  root_block_device {
    volume_type = "gp3"  # Tipo de volume SSD
    volume_size = 8      # Tamanho do volume em GiB
  }

  # Script de inicialização para montar o EFS
  user_data = <<-EOF
              #!/bin/bash
              sudo apt install -y amazon-efs-utils
              mkdir /mnt/efs
              mount -t efs ${aws_efs_file_system.example.id}:/ /mnt/efs
              EOF

  tags = {
    Name = "Frontend-EC2-Instance"
  }
}

# 14. Criar instância EC2 na Subnet Privada
resource "aws_instance" "backend_instance" {
  ami                    = "ami-0e86e20dae9224db8"  # ID da AMI
  instance_type          = "t2.micro"              # Tipo da instância
  subnet_id              = aws_subnet.private_subnet.id
  vpc_security_group_ids = [aws_security_group.private_sg.id]
  key_name               = aws_key_pair.private_instance_key.key_name

  # Script de inicialização para montar o EFS
  user_data = <<-EOF
              #!/bin/bash
              sudo apt install -y amazon-efs-utils
              mkdir /mnt/efs
              mount -t efs ${aws_efs_file_system.example.id}:/ /mnt/efs
              EOF

  tags = {
    Name = "Backend-EC2-Instance"
  }
}