# Busca dinamicamente a AMI do Amazon Linux 2023
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# 1. A Receita (Launch Template)
resource "aws_launch_template" "app_template" {
  name_prefix   = "app-template-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"
  key_name      = aws_key_pair.acesso_admin.key_name

  network_interfaces {
    security_groups = [aws_security_group.app_sg.id]
  }

  # Script de boot injetado em base64
  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Servidor executando na AZ: $(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)</h1>" > /var/www/html/index.html
              EOF
  )
}

# 2. O Orquestrador (Auto Scaling Group)
resource "aws_autoscaling_group" "app_asg" {
  name = "app-tier-asg"
  
  # Distribui os servidores entre as duas zonas privadas
  vpc_zone_identifier = [
    aws_subnet.private_1a.id, 
    aws_subnet.private_1b.id
  ]
  
  # Integração automática com o Load Balancer
  target_group_arns = [aws_lb_target_group.web_tg.arn]

  min_size         = 2 # Alta disponibilidade garantida
  max_size         = 6 # Limite de custos
  desired_capacity = 2

  launch_template {
    id      = aws_launch_template.app_template.id
    version = "$Latest"
  }
}

# Expõe a URL do Load Balancer no final da execução
output "url_da_aplicacao" {
  value       = "http://${aws_lb.web_alb.dns_name}"
  description = "Acesse esta URL no navegador"
}