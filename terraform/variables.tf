# variables.tf - Definisi variabel (versi bersih)
variable "aws_region" {
  description = "Region AWS Playground"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "Tipe EC2 (free tier friendly)"
  type        = string
  default     = "t2.micro"
}
