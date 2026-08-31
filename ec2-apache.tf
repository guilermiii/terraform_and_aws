# Buscando a AMI (Amazon Machine Image) mais recente
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Provisionando o Servidor
resource "aws_instance" "web_server_01" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"

  # Referenciando os recursos criados no Módulo 5
  subnet_id                   = aws_subnet.public_1a.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  key_name                    = aws_key_pair.acesso_admin.key_name
  associate_public_ip_address = true

  # Script de Boot (user_data) injetado via Heredoc (EOF)
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Bem-vindo ao curso de Terraform! Servidor Operacional.</h1>" > /var/www/html/index.html
              EOF

  tags = {
    Name = "Web-Server-01"
  }
}