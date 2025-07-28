# output "ami_id" {
#     value = data.aws_ami.latest-amazon-linux-image
# }
# output "ec2_public_ip" {
#     value = aws_instance.myApp-Server.public_ip
# }

output "ec2_public_ip" {
    value = module.myApp-webserver.ec2_public_ip
}

output "ami_id" {
    value = module.myApp-webserver.ami_id
}