terraform {
  required_version = "> 1.11.0"
  backend "s3" {
    bucket       = "curso-terraform-demo-aws-2026-xyz" # Valores devem ser fixos, sem variavel
    key          = "prod/main.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true # Novo state locking nativo do S3
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  # As credenciais são lidas automaticamente do AWS CLI (~/.aws/credentials)
}

resource "aws_s3_bucket" "meu_primeiro_bucket" {
  # O nome do bucket S3 deve ser globalmente único
  bucket = "curso-terraform-demo-aws-2026-xyz"

  tags = {
    Environment = "Dev"
    ManagedBy   = "Terraform"
  }
}