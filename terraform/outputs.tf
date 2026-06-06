# ==============================================================================
# OUTPUTS - outputs.tf
# ==============================================================================

output "public_ip" {
  description = "Public IP address dari EC2 instance"
  value       = aws_instance.ubuntu_vm.public_ip
}

output "ssh_command" {
  description = "Command SSH yang siap pakai"
  value       = "ssh -i ${var.ssh_key_name}.pem ubuntu@${aws_instance.ubuntu_vm.public_ip}"
}
