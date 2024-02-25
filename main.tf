//provider 設定為aws
provider "aws" {
  region = "us-east-2"
}



//vpc 設定vpc網路區段
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "my_vpc"
  }
}


//internet gateway，位於vpc裡面
resource "aws_internet_gateway" "igw" {
 vpc_id = aws_vpc.my_vpc.id

 tags = {
    Name = "my_internet_gateway"
 } 
}


resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name = "nat_eip"
  }
}


//nat_gw locate in pubic_subnet
resource "aws_nat_gateway" "nat_gw" {
  subnet_id     = aws_subnet.public_subnet.id
  allocation_id = aws_eip.nat_eip.id

  tags = {
    Name = "nat_gw"
  }
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
  tags = {
    Name = "public_route_table"
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

   tags = {
     Name = "private_route_table"
   }

}


//private_subnet_association
resource "aws_route_table_association" "private_subnet_association" {
  subnet_id = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}



resource "aws_security_group" "sg" {
  vpc_id = aws_vpc.my_vpc.id
  name   = "terraform_sg"

    ingress {
    from_port   = 0 //允許所有來源port流量進入
    to_port     = 0 //允許我有目標port
    protocol    = "-1" //允許所有協議
    cidr_blocks = ["0.0.0.0/0"] //允許所有ip流量
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  

}


//ami datasource
data "aws_ami" "my_ami" {
  most_recent = true

  filter {
    name   = "image-id"
    values = ["ami-05fb0b8c1424f266b"]
  }
}


//公網ec2
 resource "aws_instance" "public_ec2" {
  ami           = data.aws_ami.my_ami.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet.id
  security_groups = [aws_security_group.sg.id]
  key_name = aws_key_pair.public_subnet_ssh_key_pair.key_name

  tags = {
    Name = "public_ec2"
  }
}


//私網ec2
resource "aws_instance" "private_ec2" {
  ami           = data.aws_ami.my_ami.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private_subnet.id
  security_groups = [aws_security_group.sg.id]
  key_name = aws_key_pair.private_subnet_ssh_key_pair.key_name
  
  tags = {
    Name = "private_ec2"
  }
}


//產生公網的RSA私鑰
resource "tls_private_key" "public_subnet_ssh_key" {
  algorithm = "RSA"
  rsa_bits = 4096
}


//產生公網的公鑰.pem
resource "aws_key_pair" "public_subnet_ssh_key_pair" {
       key_name = "pub_subnet_public_key"
       public_key = tls_private_key.public_subnet_ssh_key.public_key_openssh
}


//把公網的私鑰到保存本地檔案
resource "local_file" "private_key_pub_subnet" {
  filename = "/Users/maxchauo/terraform/pub_subnet_private_key.pem"
  content  = tls_private_key.public_subnet_ssh_key.private_key_pem
}








//創建私網的RSA私鑰
resource "tls_private_key" "private_subnet_ssh_key" {
  algorithm = "RSA"
  rsa_bits = 4096
}


//產生私網的公鑰
resource "aws_key_pair" "private_subnet_ssh_key_pair" {
       key_name = "pvt_subnet_public_key"
       public_key = tls_private_key.private_subnet_ssh_key.public_key_openssh
}


//把私網的私鑰到保存本地檔案
resource "local_file" "private_key_pvt_subnet" {
  filename = "/Users/maxchauo/terraform/pvt_subnet_private_key.pem"
  content  = tls_private_key.private_subnet_ssh_key.private_key_pem
}





// 連線到公網的 EC2的指令
output "public_ssh_command" {
  value = "ssh -i ${basename(local_file.private_key_pub_subnet.filename)} ubuntu@${aws_instance.public_ec2.public_ip}"
}




// 連線到私網的 EC2的指令
# ssh ubuntu@{private-ip} -oProxyCommand="ssh ubuntu@{public-ip} -i {key file} -W %h:%p" -i {key file}
output "private_ssh_command" {
  value = "ssh ubuntu@${aws_instance.private_ec2.private_ip} -oProxyCommand='ssh ubuntu@${aws_instance.public_ec2.public_ip} -i ${basename(local_file.private_key_pub_subnet.filename)} -W %h:%p' -i ${basename(local_file.private_key_pvt_subnet.filename)}"
}



