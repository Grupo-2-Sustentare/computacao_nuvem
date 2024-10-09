resource "aws_efs_file_system" "example" {
  encrypted = true

  tags = {
    Name = "Main-EFS"
  }
}

resource "aws_efs_mount_target" "public_mount_target" {
  file_system_id  = aws_efs_file_system.example.id
  subnet_id       = aws_subnet.public_subnet.id
  security_groups = [aws_security_group.public_sg.id]

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_efs_mount_target" "private_mount_target" {
  file_system_id  = aws_efs_file_system.example.id
  subnet_id       = aws_subnet.private_subnet.id
  security_groups = [aws_security_group.private_sg.id]

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_security_group_rule" "allow_efs_nfs" {
  type              = "ingress"
  from_port         = 2049
  to_port           = 2049
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.public_sg.id
}