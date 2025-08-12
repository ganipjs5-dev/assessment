# Security Group for Public EC2 instances
resource "aws_security_group" "public" {
  name_prefix = "${var.name}-public-sg"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from specified CIDR"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_cidr_blocks
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name}-public-sg"
  })
}

# Security Group for Private EC2 instances
resource "aws_security_group" "private" {
  name_prefix = "${var.name}-private-sg"
  vpc_id      = var.vpc_id

  ingress {
    description     = "SSH from public instances"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.public.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name}-private-sg"
  })
}

# Data source for latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Public EC2 Instance 1
resource "aws_instance" "public_1" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.public_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.public.id]

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    hostname = "${var.name}-public-1"
  }))

  tags = merge(var.tags, {
    Name = "${var.name}-public-1"
    Type = "Public"
  })
}

# Public EC2 Instance 2
resource "aws_instance" "public_2" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.public_subnet_ids[1]
  vpc_security_group_ids = [aws_security_group.public.id]

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    hostname = "${var.name}-public-2"
  }))

  tags = merge(var.tags, {
    Name = "${var.name}-public-2"
    Type = "Public"
  })
}

# Private EC2 Instance
resource "aws_instance" "private" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.private_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.private.id]

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    hostname = "${var.name}-private-1"
  }))

  tags = merge(var.tags, {
    Name = "${var.name}-private-1"
    Type = "Private"
  })
} 