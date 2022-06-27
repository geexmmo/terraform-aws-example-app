##
# VPC
##
resource "aws_vpc" "cloudx" {
  cidr_block           = "10.10.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "cloudx"
  }
}

resource "aws_subnet" "cloudx_a" {
  vpc_id            = aws_vpc.cloudx.id
  cidr_block        = "10.10.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "cloudx_a",
    Type = "Public"
  }
}

resource "aws_subnet" "cloudx_b" {
  vpc_id            = aws_vpc.cloudx.id
  cidr_block        = "10.10.2.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "cloudx_b",
    Type = "Public"
  }
}

resource "aws_subnet" "cloudx_c" {
  vpc_id            = aws_vpc.cloudx.id
  cidr_block        = "10.10.3.0/24"
  availability_zone = data.aws_availability_zones.available.names[2]
  tags = {
    Name = "cloudx_c",
    Type = "Public"
  }
}
resource "aws_subnet" "private_db_a" {
  vpc_id            = aws_vpc.cloudx.id
  cidr_block        = "10.10.20.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "private_db_a",
    Type = "Private"
  }
}
resource "aws_subnet" "private_db_b" {
  vpc_id            = aws_vpc.cloudx.id
  cidr_block        = "10.10.21.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "private_db_b",
    Type = "Private"
  }
}
resource "aws_subnet" "private_db_c" {
  vpc_id            = aws_vpc.cloudx.id
  cidr_block        = "10.10.22.0/24"
  availability_zone = data.aws_availability_zones.available.names[2]
  tags = {
    Name = "private_db_c",
    Type = "Private"
  }
}
## ECS
resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.cloudx.id
  cidr_block        = "10.10.10.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "private_a",
    Type = "ECSPrivate"
  }
}
resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.cloudx.id
  cidr_block        = "10.10.11.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "private_b",
    Type = "ECSPrivate"
  }
}
resource "aws_subnet" "private_c" {
  vpc_id            = aws_vpc.cloudx.id
  cidr_block        = "10.10.12.0/24"
  availability_zone = data.aws_availability_zones.available.names[2]
  tags = {
    Name = "private_c",
    Type = "ECSPrivate"
  }
}

resource "aws_internet_gateway" "gwcloudx" {
  vpc_id = aws_vpc.cloudx.id
  tags = {
    Name = "main"
  }
}

resource "aws_route_table" "rtcloudx" {
  vpc_id = aws_vpc.cloudx.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gwcloudx.id
  }

  tags = {
    Name = "cloudx-rt"
  }
}

resource "aws_route_table" "rtcloudx-private" {
  vpc_id = aws_vpc.cloudx.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gwcloudx.id
  }

  tags = {
    Name = "cloudx-rt-private"
  }
}

resource "aws_route_table" "ecs-private-rt" {
  vpc_id = aws_vpc.cloudx.id

  route {
    cidr_block = "0.0.0.0/0"
    # gateway_id = aws_internet_gateway.gwcloudx.id 
    # instance_id = aws_instance.bastion.id
    network_interface_id = aws_instance.bastion.primary_network_interface_id
  }

  tags = {
    Name = "ecs-private-rt"
  }
}

resource "aws_route_table_association" "cloudx_a" {
  subnet_id      = aws_subnet.cloudx_a.id
  route_table_id = aws_route_table.rtcloudx.id
}
resource "aws_route_table_association" "cloudx_b" {
  subnet_id      = aws_subnet.cloudx_b.id
  route_table_id = aws_route_table.rtcloudx.id
}
resource "aws_route_table_association" "cloudx_c" {
  subnet_id      = aws_subnet.cloudx_c.id
  route_table_id = aws_route_table.rtcloudx.id
}

## ECS
resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.ecs-private-rt.id
}
resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.ecs-private-rt.id
}
resource "aws_route_table_association" "private_c" {
  subnet_id      = aws_subnet.private_c.id
  route_table_id = aws_route_table.ecs-private-rt.id
}