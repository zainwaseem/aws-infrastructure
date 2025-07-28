output "ec2_public_ip" {
    value = aws_instance.myApp-Server.public_ip
}

output "ami_id" {
    value = data.aws_ami.latest-amazon-linux-image
}