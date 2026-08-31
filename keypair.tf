resource "aws_key_pair" "acesso_admin" {
  key_name = "chave-admin-producao"
  # Use a função file() para ler o arquivo do seu computador
  public_key = file("~/.ssh/id_rsa.pub")
}