# terraform {
#   required_version = ">= 0.12.6"
# }

# provider "aws" {
#   version = ">= 2.28.1"
#   region  = var.region
# }

# provider "template" {
#   version = "~> 2.1"
# }

data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "eks" {
  source                         = "terraform-aws-modules/eks/aws"
  cluster_name                   = var.cluster_name
  cluster_version                = "1.21"
  cluster_endpoint_public_access = true
  vpc_id                         = var.vpc_output.id
  enable_irsa                    = true
  subnet_ids                     = [var.public_subnet_output.id, var.private_subnet_output.id]

  tags = {
    Owner           = split("/", data.aws_caller_identity.current.arn)[1]
    AutoTag_Creator = data.aws_caller_identity.current.arn
  }

  eks_managed_node_group_defaults = {
    ami_type  = "AL2_x86_64"
    disk_size = 50
  }

  eks_managed_node_groups = {
    core = {
      desired_capacity = 1
      max_capacity     = 3
      min_capacity     = 1
      instance_type    = "t3.micro"
      k8s_labels = {
        "hub.jupyter.org/node-purpose" = "core"
      }
      additional_tags = {
      }
    }
    notebook = {
      desired_capacity = 1
      max_capacity     = 10
      min_capacity     = 1

      instance_type = "t3.medium"
      k8s_labels = {
        "hub.jupyter.org/node-purpose" = "user"
      }
      additional_tags = {
      }
    }
  }
}


provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}