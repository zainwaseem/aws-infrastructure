provider "kubernetes" {
  host = module.eks.cluster_endpoint
  token = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.21.0"

  cluster_name    = "myApp-cluster"
  cluster_version = "1.29"
  subnet_ids      = module.myApp-vpc.private_subnets
  vpc_id          = module.myApp-vpc.vpc_id

  # EKS Managed Node Groups
  eks_managed_node_groups = {
    worker-group = {
      name = "worker-group" 
      instance_types = ["t2.micro"]
      asg_desired_capacity = 1
      min_size     = 1
      max_size     = 3
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
