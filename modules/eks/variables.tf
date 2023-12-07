variable "region" {
  description = "AWS Region to be used"
  type        = string
  default     = "us-east-2"
}
variable "profile" {
  description = "AWS Profile to be used"
  type        = string
  default     = "default"
}
variable "environment" {
  description = "Environment, choose from staging or production"
  type        = string
  default     = ""
}
variable "vpc_name" {
  description = "Name to be used on all vpc resources as identifier"
  type        = string
  default     = ""
}
## TODO check if needed 
variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = ""
}
variable "vpc_id" {
  description = "vpc_id have to be set"
  type        = string
  default     = ""
}
variable "vpc_private_subnets_ids" {
  description = "vpc_private_subnets_ids have to be set"
  type        = list(string)
  default     = []
}
variable "vpc_public_subnets_ids" {
  description = "vpc_private_subnets_ids have to be set"
  type        = list(string)
  default     = []
}
variable "create_admin_role" {
  description = "Whether to create admin role or not"
  type        = bool
  default     = true
}
variable "admin_role_name" {
  description = "Kubernetes Admin role name, defaults to KubernetesAdmin"
  type        = string
  default     = "k8ssysadmin"
}
variable "admin_role_groups" {
  description = "K8S RBAC group for the admin role"
  type        = list(string)
  default     = ["system:masters"]
}
variable "manage_aws_auth" {
  description = "Whether to apply the aws-auth configmap file"
  type        = bool
  default     = true
}
variable "k8s_tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}
variable "cluster_name" {
  description = "Name of the EKS cluster. Also used as a prefix in names of related resources."
  type        = string
}
variable "eks_cluster_iam_role_name" {
  description = "IAM role name for the cluster."
  type        = string
  default     = "eks"
}
variable "cluster_endpoint_public_access_cidrs" {
  description = "List of CIDR blocks which can access the Amazon EKS public API server endpoint."
  type        = list(string)
  default     = []
}
variable "node_groups_defaults" {
  description = "Map of values to be applied to all node groups. See `node_groups` module's documentaton for more details"
  type        = any
  default     = {}
}
variable "node_groups" {
  description = "Map of map of node groups to create. See `node_groups` module's documentation for more details"
  type        = any
  default     = {}
}
variable "cluster_version" {
  description = "Kubernetes version to use for the EKS cluster."
  type        = string
  default     = "1.27"
}
variable "map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth configmap."
  type        = list(string)

  default = []
}
variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))

  default = []
}
variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))

  default = []
}

variable "write_kubeconfig" {
  description = "if set to true, this will write kubeconfig to file localy."
  type        = bool
  default     = false
}

variable "cluster_security_group_rules" {
  description = "Additional inbound/outbound rules for the cluster's primary security group"
  type = list(object({
    type        = string
    cidr_blocks = list(string)
    from_port   = string
    protocol    = string
    to_port     = string
    description = string
  }))

  default = []
}

variable "enable_secret_encryption" {
  description = "Create a KMS key for encrypting Kubernetes secrets (for newly created clusters)"
  type        = bool
  default     = false
}

variable "cluster_enabled_log_types" {
  default     = []
  description = "A list of the desired control plane logging to enable. For more information, see Amazon EKS Control Plane Logging documentation (https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html)"
  type        = list(string)
}

variable "cluster_log_retention_in_days" {
  default     = 30
  description = "Number of days to retain log events. Default retention - 30 days."
  type        = number
}
