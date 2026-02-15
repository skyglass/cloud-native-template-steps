############################################################
# EKS Cluster
############################################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.15"

  cluster_name    = local.name
  cluster_version = "1.34"

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets

  enable_irsa = true

  cluster_endpoint_public_access       = true
  cluster_endpoint_public_access_cidrs = var.ingress_cidrs

  eks_managed_node_groups = {
    ng1 = {
      instance_types = ["m5.large"]
      min_size       = 2
      max_size       = 6
      desired_size   = 2
    }
  }

  cluster_addons = {
    coredns    = {}
    kube-proxy = {}
    vpc-cni    = {}

    aws-ebs-csi-driver = {
      service_account_role_arn = aws_iam_role.ebs_csi_role.arn
      most_recent              = true
    }
  }

  tags = local.tags
}

############################################################
# Fetch OIDC Provider (BREAKS THE CYCLE)
############################################################

data "aws_iam_openid_connect_provider" "eks" {
  arn = module.eks.oidc_provider_arn
}

############################################################
# IAM Role for EBS CSI
############################################################

data "aws_iam_policy_document" "ebs_csi_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.eks.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(data.aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }
  }
}

resource "aws_iam_role" "ebs_csi_role" {
  name               = "${local.name}-ebs-csi-iam-role"
  assume_role_policy = data.aws_iam_policy_document.ebs_csi_assume_role.json
}

resource "aws_iam_role_policy_attachment" "ebs_csi_attach" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.ebs_csi_role.name
}

############################################################
# EKS Auth Data
############################################################

data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster_name
}

############################################################
# Kubernetes Provider
############################################################

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.eks.token
}
