#Defining the Node IAM role and EKS policies attachment to the IAM role

resource "aws_iam_role" "bidnamic_node" {
  name = "bidnamic-node-role"

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

resource "aws_iam_role_policy_attachment" "bidnamic_worker_node" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.bidnamic_node.name
}

resource "aws_iam_role_policy_attachment" "bidnamic_cni" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.bidnamic_node.name
}

resource "aws_iam_role_policy_attachment" "bidnamic_container_registry_readonly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.bidnamic_node.name
}

#Defining local variables

locals {
  node_group_name = "bidnamic-node-group"
}

#Defining the Node Group in a private subnet, placing it in the created EKS cluster, mapping to the IAM role created for the Node Group

resource "aws_eks_node_group" "bidnamic_node_group" {
  cluster_name    = aws_eks_cluster.bidnamic_cluster.name
  node_group_name = local.node_group_name
  node_role_arn   = aws_iam_role.bidnamic_node.arn
  subnet_ids      = module.vpc.private_subnets
  instance_types = ["t2.medium"]


  scaling_config {
    desired_size = 2
    max_size     = 5
    min_size     = 1
  }

  tags = {
    Environment = "Bidnamic"
  }
  remote_access {
    # ec2_ssh_key = ""
    # source_security_group_ids = [module.bastion.security_group_id]
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.bidnamic_worker_node,
    aws_iam_role_policy_attachment.bidnamic_cni,
    aws_iam_role_policy_attachment.bidnamic_container_registry_readonly,
  ]
}