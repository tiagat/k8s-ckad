provider "aws" {
  region = "us-east-2"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

resource "aws_vpc" "main" {
  cidr_block = var.aws_cidr_block
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = false
  tags = {
    Name = "vpc-k8s-main"
  }
}

resource "aws_subnet" "public" {
  vpc_id = aws_vpc.main.id
  cidr_block = var.aws_subnet_public
  tags = {
    "Name" = "subnet-k8s-main"
  }
}

resource "aws_subnet" "private" {
  vpc_id = aws_vpc.main.id
  cidr_block = var.aws_subnet_private
  tags = {
    "Name" = "subnet-k8s-main"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "igw-subnet-public"
  }
}

resource "aws_eip" "nat" {
  vpc = true
  depends_on = [ aws_internet_gateway.gw ]
}

resource "aws_eip" "bastions" {
  vpc = true
  depends_on = [ aws_internet_gateway.gw ]
}

resource "aws_nat_gateway" "gw" {
  allocation_id = aws_eip.nat.id
  subnet_id = aws_subnet.private.id
  depends_on = [ aws_internet_gateway.gw ]
  tags = {
    Name = "nat-gateway-subnet-private"
  }
}

resource "aws_route_table" "rt_public" {
  depends_on = [ aws_internet_gateway.gw ]
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table" "rt_private" {
  depends_on = [ aws_nat_gateway.gw ]
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id =  aws_nat_gateway.gw.id
  }
}

resource "aws_route_table_association" "rt_association_public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.rt_public.id
}

resource "aws_route_table_association" "rt_association_private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.rt_private.id
}