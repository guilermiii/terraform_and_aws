resource "aws_security_group" "web_sg" {
  name        = "permitir_http"
  description = "Permite trafego HTTP de entrada e tudo de saida"
  vpc_id      = aws_vpc.main.id

  # Regras de Entrada (Ingress)
  ingress {
    description = "HTTP da Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Regras de Saída (Egress)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 significa todos os protocolos
    cidr_blocks = ["0.0.0.0/0"]
  }
}