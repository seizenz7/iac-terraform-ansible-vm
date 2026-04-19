# ==============================================================================
# MAIN INFRASTRUCTURE - main.tf
# ==============================================================================
# File ini mendefinisikan seluruh resource utama:
#   1. SSH Key Pair     — generate otomatis via Terraform
#   2. Security Group   — firewall rules (SSH + HTTP)
#   3. EC2 Instance     — VM Ubuntu untuk deploy Flask app
#   4. Outputs          — informasi koneksi setelah provisioning
# ==============================================================================


# ------------------------------------------------------------------------------
# 1. SSH KEY PAIR (Auto-Generated)
# ------------------------------------------------------------------------------
# Terraform akan generate RSA key pair secara otomatis.
# Tidak perlu ssh-keygen manual — semua dikelola sebagai state.
# ------------------------------------------------------------------------------

# Generate private + public key menggunakan provider "tls"
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA" # Algoritma enkripsi yang digunakan
  rsa_bits  = 4096  # Panjang key 4096-bit (lebih aman dari default 2048)
}

# Register public key ke AWS agar bisa dipakai EC2
resource "aws_key_pair" "devops_key" {
  key_name   = "devops-flask-key"                         # Nama key pair di AWS Console
  public_key = tls_private_key.ssh_key.public_key_openssh # Ambil public key dari resource di atas
}

# Simpan private key ke file lokal (.pem) secara otomatis
# File ini yang dipakai untuk SSH ke EC2 nanti
resource "local_file" "private_key" {
  content         = tls_private_key.ssh_key.private_key_pem # Isi file = private key PEM format
  filename        = "${path.module}/devops-flask-key.pem"   # Lokasi output file (di root module)
  file_permission = "0400"                                  # chmod 400 — read-only oleh owner saja
}


# ------------------------------------------------------------------------------
# 2. SECURITY GROUP (Firewall Rules)
# ------------------------------------------------------------------------------
# Mengatur traffic masuk (ingress) dan keluar (egress) untuk EC2.
# Port yang dibuka:
#   - 22  (SSH)  — untuk remote access
#   - 80  (HTTP) — untuk akses Flask app via browser
# ------------------------------------------------------------------------------

resource "aws_security_group" "allow_ssh_http" {
  name        = "allow_ssh_http"                     # Nama security group di AWS
  description = "Allow SSH and HTTP inbound traffic" # Deskripsi singkat fungsinya

  # --- Inbound Rules (traffic MASUK ke EC2) ---

  # Rule 1: Izinkan SSH dari mana saja
  ingress {
    from_port   = 22            # Port awal range
    to_port     = 22            # Port akhir range (sama = single port)
    protocol    = "tcp"         # SSH menggunakan TCP
    cidr_blocks = ["0.0.0.0/0"] # Sumber: semua IP (⚠️ untuk production, batasi IP spesifik)
  }

  # Rule 2: Izinkan HTTP dari mana saja
  ingress {
    from_port   = 80            # Port HTTP standar
    to_port     = 80            # Single port
    protocol    = "tcp"         # HTTP menggunakan TCP
    cidr_blocks = ["0.0.0.0/0"] # Sumber: semua IP (publik, agar bisa diakses browser)
  }

  # --- Outbound Rules (traffic KELUAR dari EC2) ---

  # Rule: Izinkan semua traffic keluar (default behavior)
  egress {
    from_port   = 0             # 0 = semua port
    to_port     = 0             # 0 = semua port
    protocol    = "-1"          # "-1" = semua protocol (TCP, UDP, ICMP, dll)
    cidr_blocks = ["0.0.0.0/0"] # Tujuan: kemana saja (internet)
  }

  # Tag untuk identifikasi di AWS Console
  tags = {
    Name = "devops-flask-sg" # Nama yang muncul di kolom "Name" AWS Console
  }
}


# ------------------------------------------------------------------------------
# 3. EC2 INSTANCE (Virtual Machine)
# ------------------------------------------------------------------------------
# VM utama tempat Flask app akan di-deploy.
# OS: Ubuntu 22.04 LTS — stabil dan long-term support.
# ------------------------------------------------------------------------------

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical (publisher resmi Ubuntu)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_instance" "ubuntu_vm" {
  ami                    = data.aws_ami.ubuntu.id                 # Selalu dapat AMI terbaru, works di region manapun
  instance_type          = var.instance_type                      # Tipe instance dari variable (e.g. t2.micro)
  key_name               = aws_key_pair.devops_key.key_name       # Pasangkan SSH key yang sudah dibuat di atas
  vpc_security_group_ids = [aws_security_group.allow_ssh_http.id] # Terapkan firewall rules dari security group

  # Tag untuk identifikasi di AWS Console
  tags = {
    Name = "devops-flask-vm" # Nama VM yang muncul di EC2 Dashboard
  }
}


# ------------------------------------------------------------------------------
# 4. OUTPUTS (Informasi Setelah Provisioning)
# ------------------------------------------------------------------------------
# Nilai-nilai ini akan ditampilkan di terminal setelah `terraform apply`.
# Berguna untuk langsung copy-paste command SSH tanpa buka AWS Console.
# ------------------------------------------------------------------------------

# Tampilkan public IP dari EC2 yang baru dibuat
output "public_ip" {
  description = "Public IP address dari EC2 instance"
  value       = aws_instance.ubuntu_vm.public_ip # IP publik untuk akses SSH dan HTTP
}

# Tampilkan command SSH yang siap pakai (tinggal copy-paste)
output "ssh_command" {
  description = "Command SSH yang siap pakai (copy-paste ke terminal)"
  value       = "ssh -i devops-flask-key.pem ubuntu@${aws_instance.ubuntu_vm.public_ip}"
  # Format: ssh -i <private_key> <user>@<ip>
  # "ubuntu" = default user untuk AMI Ubuntu di AWS
}
