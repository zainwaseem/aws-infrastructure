Add AWS infrastructure setup and user data script

- Configured AWS provider with region.
- Defined variables for VPC, subnet, and instance settings.
- Created VPC, subnet, internet gateway, and default security group resources.
- Added a data source to fetch the latest Amazon Linux AMI.
- Implemented an EC2 instance resource with user data for Docker installation.
- Introduced a user script to automate server setup with Docker and Nginx.