


resource "aws_subnet" "myApp_subnet-1" {
    vpc_id = var.vpc_id
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
    vpc_id = var.vpc_id
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
    default_route_table_id = var.default_route_table_id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.myApp-igw.id
    }
    tags = {
        Name = "${var.env_prefix}-main-rtb"
    }
}
