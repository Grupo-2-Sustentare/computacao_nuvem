# Criar Sistema de Arquivos EFS
resource "aws_efs_file_system" "efs" {
  creation_token = "my-efs"
  performance_mode = "generalPurpose"

  tags = {
    Name = "MyEFS"
  }
}

# Criar Mount Target para a Subnet Pública
resource "aws_efs_mount_target" "public_mount_target" {
  file_system_id = aws_efs_file_system.efs.id
  subnet_id      = aws_subnet.public_subnet.id
  security_groups = [aws_security_group.public_sg.id]
}

# Criar Mount Target para a Subnet Privada
resource "aws_efs_mount_target" "private_mount_target" {
  file_system_id = aws_efs_file_system.efs.id
  subnet_id      = aws_subnet.private_subnet.id
  security_groups = [aws_security_group.private_sg.id]
}