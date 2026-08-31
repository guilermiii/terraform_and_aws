# 1. A VPC Principal
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "vpc-producao"
  }
}

# 2. Subnet Pública (Para Load Balancers e Bastion Hosts)
resource "aws_subnet" "public_1a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true # Instâncias aqui ganham IP público automaticamente

  tags = {
    Name = "subnet-publica-1a"
  }
}

# 3. Subnet Privada (Para EC2 de Aplicação e RDS)
resource "aws_subnet" "private_1a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "subnet-privada-1a"
  }
}

# Internet Gateway anexado à VPC
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

# Elastic IP para o NAT Gateway (O NAT precisa de um IP fixo)
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

# NAT Gateway (Deve obrigatoriamente ficar na subnet pública)
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_1a.id

  # Garante que o IGW seja criado antes do NAT Gateway
  depends_on = [aws_internet_gateway.igw]
}