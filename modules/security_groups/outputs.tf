output "nat_sg_id" {
  value = aws_security_group.nat.id
}

output "bastion_sg_id" {
  value = aws_security_group.bastion.id
}

output "private_sg_id" {
  value = aws_security_group.private_instances.id
}

output "public_sg_id" {
  value = aws_security_group.public_instances.id
}
