 #!/bin/bash
sudo yum update -y
sudo yum install docker -y
sudo systemctl start docker
sudo systemctl enable docker
usermod -aG docker ec2-user
docker run -d -p 8080:80 --restart unless-stopped nginx