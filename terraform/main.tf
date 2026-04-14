# main.tf - Definisi lengkap EC2 + Security Group + Key Pair + Auto-save SSH key

# Key Pair untuk SSH (generated otomatis oleh Terraform)
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "devops_key" {
  key_name   = "devops-flask-key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

# Simpan private key otomatis ke file .pem
resource "local_file" "private_key" {
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = "${path.module}/devops-flask-key.pem"
  file_permission = "0400" # chmod 400 otomatis
}

# Security Group (buka port 22 SSH + 80 HTTP)
resource "aws_security_group" "allow_ssh_http" {
  name        = "allow_ssh_http"
  description = "Allow SSH and HTTP inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "devops-flask-sg"
  }
}

# EC2 Instance
resource "aws_instance" "ubuntu_vm" {
  ami                    = "ami-0c7217cdde317cfec" # Ubuntu 22.04 LTS (us-east-1)
  instance_type          = var.instance_type
  key_name               = aws_key_pair.devops_key.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh_http.id]

  tags = {
    Name = "devops-flask-vm"
  }
}

# Output
output "public_ip" {
  value = aws_instance.ubuntu_vm.public_ip
}

output "ssh_command" {
  value = "ssh -i devops-flask-key.pem ubuntu@${aws_instance.ubuntu_vm.public_ip}"
}
