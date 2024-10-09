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

# 13. Criar Auto Scaling Group para instâncias EC2 na Subnet Pública
resource "aws_launch_configuration" "frontend_lc" {
  name          = "frontend-lc"
  image_id      = "ami-0e86e20dae9224db8"  # ID da AMI
  instance_type = "t2.micro"
  key_name      = aws_key_pair.public_instance_key.key_name
  security_groups = [aws_security_group.public_sg.id]

  root_block_device {
    volume_type = "gp3"
    volume_size = 8
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt install -y amazon-efs-utils
              mkdir /mnt/efs
              mount -t efs ${aws_efs_file_system.efs.id}:/ /mnt/efs
              EOF
}

resource "aws_autoscaling_group" "frontend_asg" {
  launch_configuration = aws_launch_configuration.frontend_lc.id
  min_size             = 2
  max_size             = 4
  desired_capacity     = 2
  vpc_zone_identifier  = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]

  tag {
    key                 = "Name"
    value               = "Frontend-EC2-Instance"
    propagate_at_launch = true
  }
}

# 14. Criar Auto Scaling Group para instâncias EC2 na Subnet Privada
resource "aws_launch_configuration" "backend_lc" {
  name          = "backend-lc"
  image_id      = "ami-0e86e20dae9224db8"  # ID da AMI
  instance_type = "t2.micro"
  key_name      = aws_key_pair.private_instance_key.key_name
  security_groups = [aws_security_group.private_sg.id]

  root_block_device {
    volume_type = "gp3"
    volume_size = 8
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt install -y amazon-efs-utils
              mkdir /mnt/efs
              mount -t efs ${aws_efs_file_system.efs.id}:/ /mnt/efs
              EOF
}

resource "aws_autoscaling_group" "backend_asg" {
  launch_configuration = aws_launch_configuration.backend_lc.id
  min_size             = 2
  max_size             = 4
  desired_capacity     = 2
  vpc_zone_identifier  = [aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id]

  tag {
    key                 = "Name"
    value               = "Backend-EC2-Instance"
    propagate_at_launch = true
  }
}