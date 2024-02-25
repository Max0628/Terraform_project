//provider 
provider "aws" {
  region = "us-east-2"
}



//vpc
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "my_vpc"
  }
}


//internet gateway locate in vpc
resource "aws_internet_gateway" "igw" {
 vpc_id = aws_vpc.my_vpc.id

 tags = {
    Name = "my_internet_gateway"
 } 
}


resource "aws_eip" "nat_eip" {
  domain = "vpc"
}


//nat gw locate in pubic_subnet
resource "aws_nat_gateway" "nat_gw" {
  subnet_id     = aws_subnet.public_subnet.id
  allocation_id = aws_eip.nat_eip.id
}




//public_subnet
resource "aws_subnet" "public_subnet" {
 vpc_id = aws_vpc.my_vpc.id
 cidr_block = "10.0.0.0/24"
 availability_zone = "us-east-2a"
 map_public_ip_on_launch = true

 tags = {
   Name = "pub_subnet"
 }

}

//private_subnet
resource "aws_subnet" "private_subnet" {
vpc_id = aws_vpc.my_vpc.id
cidr_block = "10.0.1.0/24"
availability_zone = "us-east-2a"
map_public_ip_on_launch = false

tags = {
  Name = "pvt_subnet"
}
}


//public_route_table
resource "aws_route_table" "public_route_table"  {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }  
}

//public_route_association
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}


//private_route_talbe
resource "aws_route_table" "private_route_table" { 
 vpc_id = aws_vpc.my_vpc.id

 route {
    cidr_block = "0.0.0.0/0"
    gateway_id =aws_nat_gateway.nat_gw.id
 } 
   depends_on = [aws_nat_gateway.nat_gw]

}


//private_subnet_association
resource "aws_route_table_association" "private_subnet_association" {
  subnet_id = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}



resource "aws_instance" "public_ec2" {
  ami = "ami-05fb0b8c1424f266b"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public_subnet.id
}


resource "aws_instance" "private_ec2" {
  ami = "ami-05fb0b8c1424f266b"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.private_subnet.id
}