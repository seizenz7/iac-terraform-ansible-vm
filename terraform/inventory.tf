# ==============================================================================
# ANSIBLE INVENTORY GENERATOR - inventory.tf
# ==============================================================================
# Generate file inventory.ini untuk Ansible secara otomatis setelah
# EC2 berhasil dibuat dan mendapatkan public IP.

resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/inventory.ini.tpl", {
    vm_ip        = aws_instance.ubuntu_vm.public_ip
    ssh_key_path = "../terraform/${var.ssh_key_name}.pem"
    ssh_user     = "ubuntu"
  })
  filename = "${path.module}/../ansible/inventory.ini"
}
