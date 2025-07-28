
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
    vpc_id = var.vpc_id
    
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
    subnet_id = var.subnet_id
    availability_zone = var.avail_zone
    associate_public_ip_address = true
    key_name = aws_key_pair.SSH-myApp-key.key_name
    # key_name = "server-key-pair"
    user_data = file("${path.module}/user-script.sh")

    tags = {
        Name = "${var.env_prefix}-server"
    }
}