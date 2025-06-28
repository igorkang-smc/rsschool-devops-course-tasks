output "instance_ids" {
  description = "IDs of the EC2 instances"
  value       = aws_instance.ec2[*].id
}

output "public_ips" {
  description = "Public IP addresses of the EC2 instances"
  value       = aws_instance.ec2[*].public_ip
}

output "private_ips" {
  description = "Private IP addresses of the EC2 instances"
  value       = aws_instance.ec2[*].private_ip
}

output "public_dns" {
  description = "Public DNS names of the EC2 instances"
  value       = aws_instance.ec2[*].public_dns
}

output "instance_details" {
  description = "Combined details of all instances"
  value = [
    for i in range(length(aws_instance.ec2)) : {
      instance_id = aws_instance.ec2[i].id
      name        = aws_instance.ec2[i].tags.Name
      type        = aws_instance.ec2[i].tags.Type
      public_ip   = aws_instance.ec2[i].public_ip
      private_ip  = aws_instance.ec2[i].private_ip
      public_dns  = aws_instance.ec2[i].public_dns
      subnet_id   = aws_instance.ec2[i].subnet_id
      az          = aws_instance.ec2[i].availability_zone
    }
  ]
}

