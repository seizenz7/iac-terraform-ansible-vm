# ==============================================================================
# VARIABLES - variables.tf
# ==============================================================================

variable "aws_region" {
  description = "Region AWS target"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "Tipe EC2 instance"
  type        = string
  default     = "t2.micro"
}

variable "instance_name" {
  description = "Nama tag untuk EC2 instance"
  type        = string
  default     = "devops-flask-vm"
}

variable "ami_filter_name" {
  description = "Filter nama AMI untuk Ubuntu"
  type        = string
  default     = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
}

variable "ssh_key_name" {
  description = "Nama untuk SSH Key Pair"
  type        = string
  default     = "devops-flask-key"
}

variable "security_group_name" {
  description = "Nama Security Group"
  type        = string
  default     = "devops-flask-sg"
}

variable "app_port" {
  description = "Port aplikasi yang akan dibuka"
  type        = number
  default     = 80
}

variable "allowed_ssh_cidr" {
  description = "CIDR block yang diizinkan untuk SSH"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "allowed_app_cidr" {
  description = "CIDR block yang diizinkan untuk akses aplikasi"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
