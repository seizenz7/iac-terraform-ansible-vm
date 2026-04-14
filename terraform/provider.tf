# provider.tf - Konfigurasi provider AWS (versi aman untuk KodeKloud)
# Kita pakai environment variable saja (sudah di-export tadi)
# Ini best practice untuk temporary credential / session token

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  # Best practice: default tags supaya mudah track resource di AWS Console
  default_tags {
    tags = {
      Project     = "iac-terraform-ansible-vm"
      Environment = "playground"
      ManagedBy   = "terraform"
      Owner       = "seizenz7"
    }
  }
}
