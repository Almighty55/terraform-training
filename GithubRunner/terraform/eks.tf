resource "aws_iam_role" "gha" {
  name = "eks-cluster-gha"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "gha-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.gha.name
}

resource "aws_eks_cluster" "gha" {
  name     = "github_actions"
  role_arn = aws_iam_role.gha.arn
  version  = "1.27"

  vpc_config {
    subnet_ids = concat(aws_subnet.private.*.id, aws_subnet.public.*.id)
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.gha-AmazonEKSClusterPolicy
  ]
}
