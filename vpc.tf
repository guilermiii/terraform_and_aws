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

# 1. Subnet Pública na Zona B (Para a segunda "perna" do Load Balancer)
resource "aws_subnet" "public_1b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24" # Bloco CIDR diferente da 1a
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = { Name = "subnet-publica-1b" }
}

# Associa a Pública B à Route Table Pública (que aponta para o IGW)
resource "aws_route_table_association" "public_1b_assoc" {
  subnet_id      = aws_subnet.public_1b.id
  route_table_id = aws_route_table.public_rt.id
}

# 2. Subnet Privada na Zona B (Para os servidores EC2)
resource "aws_subnet" "private_1b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.20.0/24" 
  availability_zone = "us-east-1b"

  tags = { Name = "subnet-privada-1b" }
}

# Associa a Privada B à Route Table Privada (que aponta para o NAT Gateway)
# Nota: Para otimizar custos em estudos, compartilhamos o NAT Gateway da zona 1a.
resource "aws_route_table_association" "private_1b_assoc" {
  subnet_id      = aws_subnet.private_1b.id
  route_table_id = aws_route_table.private_rt.id
}