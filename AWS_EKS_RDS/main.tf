provider "aws" {
  region = "ap-south-1"
}

resource "aws_eks_cluster" "eks-cluster" {
  name = "EKS-TF"
  role_arn = "arn:aws:iam::556115946203:role/AWS-EKS-Policy"
  vpc_config {
    subnet_ids = [
      "subnet-8c1972c0",
      "subnet-01fcc669"
    ]
  }
}