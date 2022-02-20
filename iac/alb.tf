#Defining the AWS ALB Controller IAM role
#ALB policy attachment to the IAM role from a local policy file

resource "aws_iam_policy" "bidnamic_alb_controller" {
  name   = "BidnamicALBControllerPolicy"
  policy = file("iam-policy.json")
}

resource "aws_iam_role_policy_attachment" "bidnamic_alb_controller" {
  policy_arn = aws_iam_policy.bidnamic_alb_controller.arn
  role       = aws_iam_role.bidnamic_node.name
}

#Install AWS ALB Controller into the EKS Cluster using Helm

resource "helm_release" "bidnamic_alb_controller" {
  name       = "bidnamic-alb-controller"
  version    = "~>1.1.6"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  set {
    name  = "clusterName"
    value = aws_eks_cluster.bidnamic_cluster.name
  }
}