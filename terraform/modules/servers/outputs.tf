output "public_instance_1_id" {
  description = "ID of the first public EC2 instance"
  value       = aws_instance.public_1.id
}

output "public_instance_1_public_ip" {
  description = "Public IP of the first public EC2 instance"
  value       = aws_instance.public_1.public_ip
}

output "public_instance_1_private_ip" {
  description = "Private IP of the first public EC2 instance"
  value       = aws_instance.public_1.private_ip
}

output "public_instance_2_id" {
  description = "ID of the second public EC2 instance"
  value       = aws_instance.public_2.id
}

output "public_instance_2_public_ip" {
  description = "Public IP of the second public EC2 instance"
  value       = aws_instance.public_2.public_ip
}

output "public_instance_2_private_ip" {
  description = "Private IP of the second public EC2 instance"
  value       = aws_instance.public_2.private_ip
}

output "private_instance_id" {
  description = "ID of the private EC2 instance"
  value       = aws_instance.private.id
}

output "private_instance_private_ip" {
  description = "Private IP of the private EC2 instance"
  value       = aws_instance.private.private_ip
}

output "public_security_group_id" {
  description = "ID of the public security group"
  value       = aws_security_group.public.id
}

output "private_security_group_id" {
  description = "ID of the private security group"
  value       = aws_security_group.private.id
} 