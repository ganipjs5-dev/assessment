output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc_network.vpc_id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.vpc_network.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = module.vpc_network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = module.vpc_network.private_subnet_ids
}

output "public_instance_1_public_ip" {
  description = "Public IP of the first public EC2 instance"
  value       = module.servers.public_instance_1_public_ip
}

output "public_instance_2_public_ip" {
  description = "Public IP of the second public EC2 instance"
  value       = module.servers.public_instance_2_public_ip
}

output "private_instance_private_ip" {
  description = "Private IP of the private EC2 instance"
  value       = module.servers.private_instance_private_ip
}

output "bastion_host_instructions" {
  description = "Instructions for accessing the private instance via bastion host"
  value       = <<EOF
To access the private instance via bastion host:

1. SSH to the first public instance:
   ssh -i your-key.pem ec2-user@${module.servers.public_instance_1_public_ip}

2. From the public instance, SSH to the private instance:
   ssh -i your-key.pem ec2-user@${module.servers.private_instance_private_ip}

Note: Make sure your SSH key is available on the bastion host.
EOF
} 