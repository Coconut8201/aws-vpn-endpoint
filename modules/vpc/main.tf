# VPC
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = var.vpc_name
    Environment = var.environment
  }
}

# Subnet
resource "aws_subnet" "this" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.subnet_cidr
  availability_zone = var.az

  tags = {
    Name        = "${var.vpc_name}-subnet"
    Environment = var.environment
  }
}

# Route Table for Private Subnets
resource "aws_route_table" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.vpc_name}-rtb"
  }
}

# Associate Private Subnets with Route Table
resource "aws_route_table_association" "this" {
  subnet_id      = aws_subnet.this.id
  route_table_id = aws_route_table.this.id
}

# Security Group
resource "aws_security_group" "default" {
  name_prefix = "${var.vpc_name}-default-"
  description = "Default security group for ${var.vpc_name}"
  vpc_id      = aws_vpc.this.id

  # Allow SSH from VPN clients
  ingress {
    description = "SSH from VPN clients"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.101.0.0/16"]
  }

  # Allow ICMP (ping) from VPN clients
  ingress {
    description = "ICMP from VPN clients"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.101.0.0/16"]
  }

  # Allow all traffic from the same VPC
  ingress {
    description = "All traffic from same VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }

  # Allow all traffic from additional CIDR blocks (other VPCs)
  dynamic "ingress" {
    for_each = var.allowed_cidr_blocks
    content {
      description = "All traffic from ${ingress.value}"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = [ingress.value]
    }
  }

  # Allow HTTP from VPN clients (for web services)
  ingress {
    description = "HTTP from VPN clients"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.101.0.0/16"]
  }

  # Allow HTTPS from VPN clients
  ingress {
    description = "HTTPS from VPN clients"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.101.0.0/16"]
  }

  # Allow all outbound traffic
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.vpc_name}-default-sg"
  }
}
