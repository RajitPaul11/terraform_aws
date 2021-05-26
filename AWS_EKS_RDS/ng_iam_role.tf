resource "aws_iam_role" "ngrole" {
  name = "eks-node-group-role"
  depends_on = [aws_eks_cluster.eks-cluster]
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  depends_on = [aws_iam_role.ngrole]
  count = 3
  policy_arn = element(var.policy, count.index )
  role       = aws_iam_role.ngrole.name
}