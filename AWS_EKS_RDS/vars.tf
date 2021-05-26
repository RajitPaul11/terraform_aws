variable "policy" {
  type = list
  default = ["arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
              "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
              "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"]
}
