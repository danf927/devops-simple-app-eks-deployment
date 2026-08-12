module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "devops-lab-eks"
  cluster_version = "1.34" # As of 08/12/2026 standard support is 1.34 and later.

  # Grants current AWS caller identity administrative access to cluster
  enable_cluster_creator_admin_permissions = true
  cluster_endpoint_public_access           = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    default = {
      min_size     = 1
      max_size     = 3
      desired_size = 2

      instance_types = ["t3.medium"]
    }
  }
}

resource "aws_ecr_repository" "app_repo" {
  name                 = "day1-app"
  image_tag_mutability = "MUTABLE"
}