terraform {
  backend "s3" {}

  required_version = ">= 1.2.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.0.1"
    }

    local = {
      source  = "hashicorp/local"
      version = "~> 2.4.0"
    }

    null = {
      source  = "hashicorp/null"
      version = "~> 3.2.2"
    }

    template = {
      source  = "hashicorp/template"
      version = "~> 2.2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.10"
    }
  }
}

provider "aws" {
  region  = var.region
  profile = var.profile
  shared_config_files = ["/home/emdad/.aws/config"]
  shared_credentials_file = ["/home/emdad/.aws/credentials"]
}
data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
}

locals {
  cluster_iam_role_name = "${var.eks_cluster_iam_role_name}-${var.cluster_name}"
  policy_arn_prefix     = "arn:${data.aws_partition.current.partition}:iam::aws:policy"
}

# Creating initial KubernetesAdmin role to use for assuming
module "iam_assumable_role_admin" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 5.32.0"

  create_role = var.create_admin_role

  role_name         = var.admin_role_name
  role_requires_mfa = false

  tags = {
    Name        = var.admin_role_name
    Environment = var.environment
  }
  trusted_role_arns = [
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
  ]
}
locals {

  admin_role = var.create_admin_role ? [{
    rolearn  = module.iam_assumable_role_admin.this_iam_role_arn
    username = var.admin_role_name
    groups   = var.admin_role_groups
  }] : []
}

resource "aws_kms_key" "eks" {
  count = var.enable_secret_encryption ? 1 : 0

  description         = "EKS Secret Encryption Key"
  enable_key_rotation = true

  tags = {
    Environment = var.environment
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name                         = var.cluster_name
  cluster_version                      = var.cluster_version
  cluster_endpoint_public_access       = true
  cluster_endpoint_private_access      = true
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs
  vpc_id                               = var.vpc_id
  subnets                              = concat(var.vpc_private_subnets_ids, var.vpc_public_subnets_ids)
  tags                                 = var.k8s_tags
  cluster_enabled_log_types            = var.cluster_enabled_log_types
  cluster_log_retention_in_days        = var.cluster_log_retention_in_days
  manage_cluster_iam_resources         = true
  node_groups_defaults = merge(
    {
      ami_type  = "AL2_x86_64"
      disk_size = 25
      subnets   = var.vpc_private_subnets_ids
    },
    var.node_groups_defaults
  )

  manage_aws_auth                              = var.manage_aws_auth
  node_groups                                  = var.node_groups
  map_roles                                    = flatten(concat(local.admin_role, var.map_roles))
  map_users                                    = var.map_users
  map_accounts                                 = var.map_accounts
  kubeconfig_aws_authenticator_additional_args = ["-r", module.iam_assumable_role_admin.this_iam_role_arn]
  write_kubeconfig                             = var.write_kubeconfig
  enable_irsa                                  = true

  cluster_encryption_config = var.enable_secret_encryption ? [
    {
      provider_key_arn = aws_kms_key.eks[0].arn
      resources        = ["secrets"]
    }
  ] : []
}

data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {}
data "aws_partition" "current" {}

data "aws_iam_policy_document" "eks-cluster" {
  statement {
    sid    = "EksClusterEc2"
    effect = "Allow"

    actions = [
      "ec2:DescribeInternetGateways",
      "ec2:DescribeAccountAttributes",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "eks-cluster" {
  name_prefix = "eks-cluster-${var.cluster_name}"
  description = "EKS cluster policy for ${var.cluster_name}"
  policy      = data.aws_iam_policy_document.eks-cluster.json
  path        = "/"
}
resource "aws_iam_role_policy_attachment" "attach-cluster-extra-policy" {
  policy_arn = aws_iam_policy.eks-cluster.arn
  role       = module.eks.cluster_iam_role_name

  depends_on = [module.eks]
}

resource "aws_security_group_rule" "sg-rules" {
  for_each          = { for rule in var.cluster_security_group_rules : rule.description => rule }
  type              = each.value.type
  cidr_blocks       = each.value.cidr_blocks
  from_port         = each.value.from_port
  protocol          = each.value.protocol
  to_port           = each.value.to_port
  description       = each.value.description
  security_group_id = module.eks.cluster_primary_security_group_id

  depends_on = [module.eks]
}