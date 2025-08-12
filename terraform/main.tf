# Configure AWS Provider
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.tags
  }
}

# Data source for availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# VPC and Networking Module
module "vpc_network" {
  source = "./modules/vpc-network"

  name               = var.project_name
  vpc_cidr           = var.vpc_cidr
  availability_zones = slice(data.aws_availability_zones.available.names, 0, 3)
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  tags               = var.tags
}

# EC2 Servers Module
module "servers" {
  source = "./modules/servers"

  name               = var.project_name
  vpc_id             = module.vpc_network.vpc_id
  public_subnet_ids  = module.vpc_network.public_subnet_ids
  private_subnet_ids = module.vpc_network.private_subnet_ids
  key_name           = var.key_name
  instance_type      = var.instance_type
  ssh_cidr_blocks    = var.ssh_cidr_blocks
  tags               = var.tags

  depends_on = [module.vpc_network]
} 