resource "aws_vpc" "demo_vpc" {
  cidr_block           = "192.168.0.0/22"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"

  tags = {
    Name = "demo-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.demo_vpc.id

  tags = {
    Name = "demo-vpc-igw"
  }
}

# Public Subnets
resource "aws_subnet" "public" {
  count             = 2
  vpc_id            = aws_vpc.demo_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.demo_vpc.cidr_block, 3, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "demo-vpc-subnet-public-${data.aws_availability_zones.available.names[count.index]}"
  }
}

# Private App Subnets
resource "aws_subnet" "private_app" {
  count             = 2
  vpc_id            = aws_vpc.demo_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.demo_vpc.cidr_block, 3, count.index + 2)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "demo-vpc-subnet-App${count.index + 1}"
  }
}

# Private DB Subnets
resource "aws_subnet" "private_db" {
  count             = 2
  vpc_id            = aws_vpc.demo_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.demo_vpc.cidr_block, 3, count.index + 4)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "demo-vpc-subnet-DB${count.index + 1}"
  }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"
}

# NAT Gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "demo-vpc-nat"
  }

  depends_on = [aws_internet_gateway.igw]
}

# Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.demo_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "demo-vpc-public-rt"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.demo_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "demo-vpc-private-rt"
  }
}

# Route Table Associations
resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_app" {
  count          = 2
  subnet_id      = aws_subnet.private_app[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_db" {
  count          = 2
  subnet_id      = aws_subnet.private_db[count.index].id
  route_table_id = aws_route_table.private.id
}

# SSM VPC Endpoints for Session Manager
resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = aws_vpc.demo_vpc.id
  service_name        = "com.amazonaws.us-east-1.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private_app[*].id
  security_group_ids  = [aws_security_group.vpce.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id              = aws_vpc.demo_vpc.id
  service_name        = "com.amazonaws.us-east-1.ssmmessages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private_app[*].id
  security_group_ids  = [aws_security_group.vpce.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id              = aws_vpc.demo_vpc.id
  service_name        = "com.amazonaws.us-east-1.ec2messages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private_app[*].id
  security_group_ids  = [aws_security_group.vpce.id]
  private_dns_enabled = true
}

# Security group for VPC endpoints
resource "aws_security_group" "vpce" {
  name        = "VPCE-SG"
  description = "Security group for VPC endpoints"
  vpc_id      = aws_vpc.demo_vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.demo_vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "VPCE-SG"
  }
}

# Data source for AZs
data "aws_availability_zones" "available" {
  state = "available"
}