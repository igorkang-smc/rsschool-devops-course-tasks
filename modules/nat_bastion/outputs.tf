output "nat_bastion_instance_id" {
  value = aws_instance.nat_bastion.id
}

output "nat_bastion_public_ip" {
  value = aws_instance.nat_bastion.public_ip
}

output "nat_bastion_private_ip" {
  value = aws_instance.nat_bastion.private_ip
}

output "nat_network_interface_id" {
  value = aws_instance.nat_bastion.primary_network_interface_id
}

output "nat_instance_id" {
  description = "ID of the NAT server instance"
  value       = aws_instance.nat_bastion.id
}

output "nat_instance_public_ip" {
  description = "Public IP address of the NAT server instance"
  value       = aws_instance.nat_bastion.public_ip
}