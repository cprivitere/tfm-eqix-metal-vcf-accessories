output "ssh_private_key" {
  description = "The private key for the SSH keypair"
  value       = module.ssh.ssh_private_key
  sensitive   = false
}
output "bastion_public_ip" {
  description = "The public IP address of the bastion host"
  value       = equinix_metal_device.bastion.access_public_ipv4
}
output "ssh_forward_command" {
  description = "SSH port forward command to use to connect to the Prism GUI"
  value       = "ssh -L 8000:172.16.11.101:443 -L 8100:172.16.10.3:443 -i ${module.ssh.ssh_private_key} root@${equinix_metal_device.bastion.access_public_ipv4}"
}
output "management_host_public_ip" {
  description = "The public IP address of the windows management host"
  value       = equinix_metal_device.management_host.access_public_ipv4
}
