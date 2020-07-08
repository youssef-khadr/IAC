data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "terraformVPC" {
  cidr_block       = var.vpcCIDR
  instance_tenancy = "default"

  tags = {
    Name = "Cet014_VPC"
  }
}
resource "aws_internet_gateway" "terraformGateway" {
  vpc_id = aws_vpc.terraformVPC.id

  tags = {
    Name = "Cet014_InternetGateway"
  }
}
resource "aws_subnet" "publicSN1" {
  vpc_id     = aws_vpc.terraformVPC.id
  cidr_block = var.publicSubnet1CIDR
  availability_zone = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "Cet014_PublicSN1_AZ1"
  }
}
resource "aws_subnet" "publicSN2" {
  vpc_id     = aws_vpc.terraformVPC.id
  cidr_block = var.publicSubnet2CIDR
  availability_zone = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true
  tags = {
    Name = "Cet014_PublicSN2_AZ2"
  }
}
resource "aws_subnet" "privateSN1" {
  vpc_id     = aws_vpc.terraformVPC.id
  cidr_block = var.privateSubnet1CIDR
  availability_zone = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false
  tags = {
    Name = "Cet014_PrivateSN1_AZ1"
  }
}
resource "aws_subnet" "privateSN2" {
  vpc_id     = aws_vpc.terraformVPC.id
  cidr_block = var.privateSubnet2CIDR
  availability_zone = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = false
  tags = {
    Name = "Cet014_PrivateSN2_AZ2"
  }
}
resource "aws_security_group" "publicSecurityGroup" {
  name        = "Cet014_PublicSecurityGroup"
  vpc_id      = aws_vpc.terraformVPC.id

  ingress {
    description = "TLS from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "privateSecurityGroup" {
  name        = "Cet014_PrivateSecurityGroup"
  vpc_id      = aws_vpc.terraformVPC.id

  ingress =[{
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.terraformVPC.cidr_block]
    ipv6_cidr_blocks = null
    prefix_list_ids = null
    security_groups = null
    self = null
     },
    {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.terraformVPC.cidr_block]
    ipv6_cidr_blocks = null
    prefix_list_ids = null
    security_groups = null
    self = null
    }]
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}
resource "aws_route_table" "publicRouteTable" {
  vpc_id = aws_vpc.terraformVPC.id


  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terraformGateway.id
  }
}
resource "aws_route_table_association" "publicSN1RouteRable" {
  subnet_id      = aws_subnet.publicSN1.id
  route_table_id = aws_route_table.publicRouteTable.id
}
resource "aws_route_table_association" "publicSN2RouteRable" {
  subnet_id      = aws_subnet.publicSN2.id
  route_table_id = aws_route_table.publicRouteTable.id
}

resource "aws_route_table" "privateRouteTable" {
  vpc_id = aws_vpc.terraformVPC.id


  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.terraformNatGateway.id
  }
}
resource "aws_route_table_association" "privateSN1RouteRable" {
  subnet_id      = aws_subnet.privateSN1.id
  route_table_id = aws_route_table.privateRouteTable.id
}
resource "aws_route_table_association" "privateSN2RouteRable" {
  subnet_id      = aws_subnet.privateSN2.id
  route_table_id = aws_route_table.privateRouteTable.id
}

resource "aws_eip" "terraformNatEIP" {
  vpc = true
  depends_on = [aws_internet_gateway.terraformGateway]
}
resource "aws_nat_gateway" "terraformNatGateway" {
  allocation_id = aws_eip.terraformNatEIP.id
  subnet_id     = aws_subnet.publicSN1.id
}
