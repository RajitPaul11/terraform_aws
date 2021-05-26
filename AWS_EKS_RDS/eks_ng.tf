resource "aws_eks_node_group" "eks_ng" {
  cluster_name = "EKS-TF"
  depends_on = [aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy]
  node_group_name = "ng1"
  node_role_arn = "arn:aws:iam::556115946203:role/eks-node-group-role"
  subnet_ids = [
      "subnet-8c1972c0",
      "subnet-01fcc669"
  ]
  scaling_config {
    desired_size = 2
    max_size = 3
    min_size = 1
  }
}