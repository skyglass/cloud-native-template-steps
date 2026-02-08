module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.15"

  cluster_name    = local.name

  # https://github.com/gavinbunney/terraform-provider-kubectl/issues/270
  # cluster_version = "1.27"
  cluster_version = "1.34"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets

  cluster_endpoint_public_access = true
  cluster_endpoint_public_access_cidrs = var.ingress_cidrs

  eks_managed_node_groups = {
    ng1 = {
      instance_types = ["m5.large"]
      min_size     = 2
      max_size     = 6
      desired_size = 2
    }
  }

  cluster_addons = {
    coredns    = {}
    kube-proxy = {}
    vpc-cni    = {}    

    aws-ebs-csi-driver = {
      service_account_role_arn = module.ebs_csi_irsa.iam_role_arn
    }

  }

  tags = local.tags

}

// added for EBS-CSI

module "ebs_csi_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name             = "${local.name}-ebs-csi-controller-could-not-reuse"
  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
}