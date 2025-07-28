provider "aws" {
    region = "us-east-1"
}

# VPC Infrastructure
resource "aws_vpc" "myApp_vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name = "${var.env_prefix}-vpc"
    }

  
}

module "myApp-subnet" {
    source = "./modules/subnet"
    vpc_id =aws_vpc.myApp_vpc.id
    avail_zone = var.avail_zone
    env_prefix = var.env_prefix
    subnet_cidr_block = var.subnet_cidr_block
    default_route_table_id = aws_vpc.myApp_vpc.default_route_table_id
}


module "myApp-webserver" {
    source = "./modules/webserver"
    vpc_id = aws_vpc.myApp_vpc.id
    avail_zone = var.avail_zone
    env_prefix = var.env_prefix
    my_public_key_location = var.my_public_key_location
    # my_private_key_location = var.my_private_key_location
    instance_Type = var.instance_Type
    my_ip = var.my_ip
    subnet_id = module.myApp-subnet.subnet.id
}