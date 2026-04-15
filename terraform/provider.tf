# ==============================================================================
# PROVIDER CONFIGURATION - provider.tf
# ==============================================================================
# File ini mendefinisikan provider yang digunakan oleh Terraform.
#
# Credentials diambil dari environment variables:
#   - AWS_ACCESS_KEY_ID
#   - AWS_SECRET_ACCESS_KEY
#   - AWS_SESSION_TOKEN (opsional, untuk temporary credentials)
#
# Best practice: tidak hardcode credentials di file .tf
# ==============================================================================

# ------------------------------------------------------------------------------
# Terraform Settings
# ------------------------------------------------------------------------------
# Blok ini menentukan versi provider yang dibutuhkan agar semua
# anggota tim menggunakan versi yang kompatibel.
# ------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.5.0"	# Mengunci versi CLI Terraform
  required_providers {
    aws = {
      source  = "hashicorp/aws"   # Registry resmi HashiCorp untuk AWS provider
      version = "~> 5.0"          # Izinkan versi 5.x (minor update), lock major version
    }
  }
}

# ------------------------------------------------------------------------------
# AWS Provider
# ------------------------------------------------------------------------------
# Konfigurasi koneksi ke AWS. Region diambil dari variable agar
# fleksibel dan bisa di-override tanpa mengubah file ini.
# ------------------------------------------------------------------------------
provider "aws" {
  region = var.aws_region          # Region target deploy (e.g. ap-southeast-1)

  # Default tags — otomatis diterapkan ke SEMUA resource yang dibuat
  # Terraform di provider ini. Berguna untuk:
  #   - Cost tracking di AWS Billing
  #   - Filtering resource di AWS Console
  #   - Identifikasi ownership & environment
  default_tags {
    tags = {
      Project     = "iac-terraform-ansible-vm"  # Nama project
      Environment = "playground"                 # Stage environment
      ManagedBy   = "terraform"                  # Tool yang mengelola resource
      Owner       = "seizenz7"                   # Penanggung jawab resource
    }
  }
}
