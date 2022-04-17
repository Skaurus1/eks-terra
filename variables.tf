variable "region" {
  type = string
  default = "ap-south-1"
}

variable "k8s" {
  type = object({
    cluster_name    = string
    cluster_version = string
    instance_types  = list(string)
    capacity_type   = string
    min_size        = number
    max_size        = number
    desired_size    = number
    cloudwatch      = bool
  })

  default = {
    cluster_name    = "my-cluster"
    cluster_version = "1.21"
    instance_types  = ["m5a.large"]
    capacity_type   = "SPOT"
    min_size        = 2
    max_size        = 10
    desired_size    = 3
    cloudwatch      = true
  }
}

variable "vpc" {
  type = object({
    name            = string
    cidr            = string
    azs             = list(string)
    private_subnets = list(string)
    public_subnets  = list(string)
  })

  default = {
    name            = "k8s-vpc"
    cidr            = "10.0.0.0/16"
    azs             = ["ap-south-1a","ap-south-1b","ap-south-1c"]
    private_subnets = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
    public_subnets  = ["10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24"]
  }
}
