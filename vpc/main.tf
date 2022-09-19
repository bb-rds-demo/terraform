variable vpc_name {}
variable vpc_cidr {}
variable public_cidr_01 {}
variable public_cidr_02 {}
variable private_cidr_01 {}
variable private_cidr_02 {}

resource "aws_vpc" "rds_demo_vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "public_subnet_01" {
  vpc_id     = aws_vpc.rds_demo_vpc.id
  cidr_block = var.public_cidr_01
  availability_zone = "eu-west-2a"

  tags = {
    Name = "public-subnet-01"
  }
}

resource "aws_subnet" "public_subnet_02" {
  vpc_id     = aws_vpc.rds_demo_vpc.id
  cidr_block = var.public_cidr_02
  availability_zone = "eu-west-2b"

  tags = {
    Name = "public-subnet-02"
  }
}

resource "aws_subnet" "private_subnet_01" {
  vpc_id     = aws_vpc.rds_demo_vpc.id
  cidr_block = var.private_cidr_01
  availability_zone = "eu-west-2a"

  tags = {
    Name = "private-subnet-01"
  }
}

resource "aws_subnet" "private_subnet_02" {
  vpc_id     = aws_vpc.rds_demo_vpc.id
  cidr_block = var.private_cidr_02
  availability_zone = "eu-west-2b"

  tags = {
    Name = "private-subnet-02"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.rds_demo_vpc.id

  tags = {
    Name = "rds-demo-internet-gateway"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.rds_demo_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "rds-demo-public-route-table"
  }
}

resource "aws_route_table_association" "public_subnet_01_association" {
  subnet_id      = aws_subnet.public_subnet_01.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_02_association" {
  subnet_id      = aws_subnet.public_subnet_02.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table" "private_route_table01" {
  vpc_id = aws_vpc.rds_demo_vpc.id
  tags = {
    Name = "rds-demo-private-route-table-01"
  }
}

resource "aws_route_table_association" "private_subnet_01_association" {
  subnet_id      = aws_subnet.private_subnet_01.id
  route_table_id = aws_route_table.private_route_table01.id
}

resource "aws_route_table" "private_route_table02" {
  vpc_id = aws_vpc.rds_demo_vpc.id
  tags = {
    Name = "rds-demo-private-route-table-02"
  }
}

resource "aws_route_table_association" "private_subnet_02_association" {
  subnet_id      = aws_subnet.private_subnet_02.id
  route_table_id = aws_route_table.private_route_table02.id
}

output "vpc_id" {
  value = aws_vpc.rds_demo_vpc.id
}

output "public_subnet_01" {
  value = aws_subnet.public_subnet_01.id
}

output "public_subnet_02" {
  value = aws_subnet.public_subnet_02.id
}

output "private_subnet_01" {
  value = aws_subnet.private_subnet_01.id
}

output "private_subnet_02" {
  value = aws_subnet.private_subnet_02.id
}
