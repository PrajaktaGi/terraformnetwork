terraform { 
   required_providers { 
     aws = { 
       source = "hashicorp/aws" 
       version = "5.61.0" 
     } 
     
  } 
 } 

 provider "aws" { 
   region = "us-west-2" 
 } 
#VPC creation
 resource "aws_vpc" "myvpc" {
  cidr_block = "10.0.0.0/16"

tags={
    Name="MyVPC"
}
}

#Subnet Creation
#Public Subnet
resource "aws_subnet" "publicSubnet1" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "PublicSubnet1"
  }
}
resource "aws_subnet" "publicSubnet2" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-west-2b"
  map_public_ip_on_launch = true
  tags = {
    Name = "PublicSubnet2"
  }
}

#Private Subnet
resource "aws_subnet" "privateSubnet1" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-west-2a"
  tags = {
    Name = "PrivateSubnet1"
  }
}

resource "aws_subnet" "privateSubnet2" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "us-west-2b"
  tags = {
    Name = "PrivateSubnet2"
  }
}

#internetgateway
resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = "main-internet-gateway"
  }
}

resource "aws_eip" "ElasticIp1" {
  
}

resource "aws_eip" "ElasticIp2" {
  
}
#natgateway
resource "aws_nat_gateway" "NatGW1" {
  allocation_id = aws_eip.ElasticIp1.id
  subnet_id     = aws_subnet.publicSubnet1.id
  tags = {
    Name = "main-nat-gateway1"
  }
}

resource "aws_nat_gateway" "NatGW2" {
  allocation_id = aws_eip.ElasticIp2.id
  subnet_id     = aws_subnet.publicSubnet2.id
  tags = {
    Name = "main-nat-gateway2"
  }
}


#Creating Public Route table
resource "aws_route_table" "PublicRouteTable" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }
  tags = {
    Name = "public-route-table"
  }
}

#Creating Private Route table
resource "aws_route_table" "PrivateRouteTable1" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NatGW1.id
  }
  tags = {
    Name = "private-route-table1"
  }
}

resource "aws_route_table" "PrivateRouteTable2" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NatGW2.id
  }

  tags = {
    Name = "private-route-table2"
  }
}

# Associate the public subnet with the public route table
resource "aws_route_table_association" "Public1" {
  subnet_id      = aws_subnet.publicSubnet1.id
  route_table_id = aws_route_table.PublicRouteTable.id
}

resource "aws_route_table_association" "Public2" {
  subnet_id      = aws_subnet.publicSubnet2.id
  route_table_id = aws_route_table.PublicRouteTable.id
}

# Associate the public subnet with the public route table
resource "aws_route_table_association" "Private1" {
  subnet_id      = aws_subnet.privateSubnet1.id
  route_table_id = aws_route_table.PrivateRouteTable1.id
}

resource "aws_route_table_association" "Private2" {
  subnet_id      = aws_subnet.privateSubnet2.id
  route_table_id = aws_route_table.PrivateRouteTable2.id
}

/*resource "aws_key_pair" "MyKey" {
  key_name   = "deployer-key"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINA59it6hLDblzdAt7c4iK3etHYMZEl9q+Y3szfd9rAq praja@hp"
}

#EC2 creation in public subnet
resource "aws_instance" "PublicInstance" {
  ami           = "ami-0648742c7600c103f" # us-west-2
  instance_type = "t2.micro"
  subnet_id= aws_subnet.publicSubnet2.vpc_id
  key_name = "MyKeyPair.pem"

  tags = {
    Name= "PublicInstance"
  }
}

#EC2 creation in private subnet
resource "aws_instance" "PrivateInstance" {
  ami           = "ami-0648742c7600c103f" # us-west-2
  instance_type = "t2.micro"
  subnet_id= aws_subnet.privateSubnet2.id
  key_name = "MyKeyPair.pem"

  tags = {
    Name= "PrivateInstance"
  }
}*/
