provider "aws" {
    region = "us-east-1"
}

variable "vpc_cidr_block" {
}
variable "subnet_cidr_block" {
}
variable "avail_zone" {

}

variable "env_prefix" {

}
variable "my_ip" {
  
}
variable "my_public_key_location" {

}
variable "my_private_key_location" {

}
variable "instance_Type"{}



# VPC Infrastructure
resource "aws_vpc" "myApp_vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name = "${var.env_prefix}-vpc"
    }

  
}


resource "aws_subnet" "myApp_subnet-1" {
    vpc_id = aws_vpc.myApp_vpc.id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.avail_zone
    tags = {
        Name = "${var.env_prefix}-subnet-1"
    }
}


# Route Table-1
# resource "aws_route_table" "myApp-route-table" {
#     vpc_id = aws_vpc.myApp_vpc.id

#     route {
#         cidr_block = "0.0.0.0/0"
#         gateway_id =aws_internet_gateway.myApp-igw.id
#     }

#     tags = {
#         Name = "${var.env_prefix}-rtb"
#     }

# }


resource "aws_internet_gateway" "myApp-igw" {
    vpc_id = aws_vpc.myApp_vpc.id
    tags = {
        Name = "${var.env_prefix}-igw"
    }
}



# Route Table Association-2

resource "aws_route_table_association" "a-rtb" {
    subnet_id = aws_subnet.myApp_subnet-1.id
    # route_table_id = aws_route_table.myApp-route-table.id
    route_table_id = aws_default_route_table.main-rtb.id
}



# Default Route table For Subnet-3

resource "aws_default_route_table" "main-rtb" {
    default_route_table_id = aws_vpc.myApp_vpc.default_route_table_id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.myApp-igw.id
    }
    tags = {
        Name = "${var.env_prefix}-main-rtb"
    }
}


# Security Group for My server

# resource "aws_security_group" "myApp-sg" {
#     name = "myApp-sg"
#     vpc_id = aws_vpc.myApp_vpc.id
    
#     ingress {
#         from_port = 22
#         to_port = 22
#         protocol = "tcp"
#         cidr_blocks = [var.my_ip]
#     }
    
#     ingress {
#         from_port = 8080
#         to_port = 8080
#         protocol = "tcp"
#         cidr_blocks = ["0.0.0.0/0"]
#     }
    
#     egress {
#         from_port = 0
#         to_port = 0
#         protocol = "-1"
#         cidr_blocks = ["0.0.0.0/0"]
#     }
    
#     tags = {
#         Name = "${var.env_prefix}-sg"
#     }
# }

# Default Security Group

resource "aws_default_security_group" "myApp-default-sg" {
    vpc_id = aws_vpc.myApp_vpc.id
    
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.my_ip]
    }
    
    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    tags = {
        Name = "${var.env_prefix}-sg"
    }
}

# Fetch Latest Amazon Linux Image
data "aws_ami" "latest-amazon-linux-image" {
    most_recent = true
    owners = ["amazon"]
    filter {
        name = "name"
        values = ["amzn2-ami-hvm-*-x86_64-gp2"]
    }

    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }

    filter {
        name = "root-device-type"
        values = ["ebs"]
    }
    
}

resource "aws_key_pair" "SSH-myApp-key" {
    key_name = "server-key"
    public_key = file(var.my_public_key_location)
}




resource "aws_instance" "myApp-Server" {
    ami = data.aws_ami.latest-amazon-linux-image.id
    instance_type =var.instance_Type
    vpc_security_group_ids = [aws_default_security_group.myApp-default-sg.id]
    subnet_id = aws_subnet.myApp_subnet-1.id
    availability_zone = var.avail_zone
    associate_public_ip_address = true
    key_name = aws_key_pair.SSH-myApp-key.key_name
    # key_name = "server-key-pair"
    # user_data = file("user-script.sh")



    provisioner "file" {
        source = "user-script.sh"
        destination = "/home/ec2-user/user-script.sh"
    }

    connection {
      type = "ssh"
      host = self.public_ip
      user = "ec2-user"
      private_key = file(var.my_private_key_location)
    }

    # Provisioner for remote-exec
    provisioner "remote-exec" {
        script = "user-script.sh"
        # inline = [
        #     "export ENV=dev",
        #     "mkdir newdir"
        # ]
    }

    provisioner "local-exec" {
        command = "echo ${aws_instance.myApp-Server.public_ip} > ip_address.txt"
    }
    

    tags = {
        Name = "${var.env_prefix}-server"
    }
}
# output "ami_id" {
#     value = data.aws_ami.latest-amazon-linux-image
# }
output "ec2_public_ip" {
    value = aws_instance.myApp-Server.public_ip
}