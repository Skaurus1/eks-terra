terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.region
}

provider "helm" {
  alias = "helm"
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    exec {
      api_version = "client.authentication.k8s.io/v1alpha1"
      args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.cluster.name]
      command     = "aws"
    }
  }
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.0"

  name                 = var.vpc.name
  cidr                 = var.vpc.cidr
  azs                  = var.vpc.azs
  private_subnets      = var.vpc.private_subnets
  public_subnets       = var.vpc.public_subnets
  enable_nat_gateway = true
  single_nat_gateway = false
  one_nat_gateway_per_az = true
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.20.2"

  cluster_name    = var.k8s.cluster_name
  cluster_version = var.k8s.cluster_version
  subnet_ids      = module.vpc.private_subnets

  create_cloudwatch_log_group = var.k8s.cloudwatch

  vpc_id = module.vpc.vpc_id

  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {}
  }

  eks_managed_node_groups = {
      blue = {
      min_size     = var.k8s.min_size
      max_size     = var.k8s.max_size
      desired_size = var.k8s.min_size

      instance_types = var.k8s.instance_types
      capacity_type  = var.k8s.capacity_type
    }
    green = {
      min_size     = var.k8s.min_size
      max_size     = var.k8s.max_size
      desired_size = var.k8s.min_size

      instance_types = var.k8s.instance_types
      capacity_type  = var.k8s.capacity_type
    }

  }
}

resource "helm_release" "CALICO" {
  name       = "calico"

  repository = "https://projectcalico.docs.tigera.io/charts"
  chart      = "projectcalico/tigera-operator"

  set {
    name  = "CALICO_IPV4POOL_CIDR"
    value = "192.168.0.0/16"
  }
}
