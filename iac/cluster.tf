#Defining the Cluster IAM role and EKS Cluster policy attachment to the IAM role

resource "aws_iam_role" "bidnamic_cluster" {
  name = "bidnamic-cluster"

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

resource "aws_iam_role_policy_attachment" "bidnamic_cluster" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.bidnamic_cluster.name
}

#Creating the EKS Cluster and mapping to the IAM role created for the cluster

resource "aws_eks_cluster" "bidnamic_cluster" {
  name     = local.cluster_name
  role_arn = aws_iam_role.bidnamic_cluster.arn
  version  = "1.19"

  vpc_config {
    subnet_ids              = module.vpc.private_subnets
    endpoint_private_access = true
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.bidnamic_cluster,
  ]
}

#EKS Cluster authentication for providers

data "aws_eks_cluster_auth" "bidnamic_k8s_auth" {
  name = aws_eks_cluster.bidnamic_cluster.name
}

provider "kubernetes" {
  host                   = aws_eks_cluster.bidnamic_cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.bidnamic_cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.bidnamic_k8s_auth.token
}

provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.bidnamic_cluster.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.bidnamic_cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.bidnamic_k8s_auth.token
  }
}