## AWS EKS Module 
This uses the public [EKS module](https://github.com/terraform-aws-modules/terraform-aws-eks) and others to bootstrap k8s with irsa for cluster-autoscaler


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13.0 |
| aws | ~> 3.10 |
| kubernetes | ~> 1.11 |
| local | ~> 2.0.0 |
| null | ~> 3.0.0 |
| random | ~> 3.0.1 |
| template | ~> 2.2 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 3.10 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| eks | terraform-aws-modules/eks/aws | ~> v13.2.0 |
| iam_assumable_role_admin | terraform-aws-modules/iam/aws//modules/iam-assumable-role | ~> 3.8 |
| iam_assumable_role_autoscaler | terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc | 3.8.0 |

## Resources

| Name |
|------|
| [aws_availability_zones](https://registry.terraform.io/providers/hashicorp/aws/3.10/docs/data-sources/availability_zones) |
| [aws_caller_identity](https://registry.terraform.io/providers/hashicorp/aws/3.10/docs/data-sources/caller_identity) |
| [aws_eks_cluster_auth](https://registry.terraform.io/providers/hashicorp/aws/3.10/docs/data-sources/eks_cluster_auth) |
| [aws_eks_cluster](https://registry.terraform.io/providers/hashicorp/aws/3.10/docs/data-sources/eks_cluster) |
| [aws_iam_policy_document](https://registry.terraform.io/providers/hashicorp/aws/3.10/docs/data-sources/iam_policy_document) |
| [aws_iam_policy](https://registry.terraform.io/providers/hashicorp/aws/3.10/docs/resources/iam_policy) |
| [aws_iam_role_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/3.10/docs/resources/iam_role_policy_attachment) |
| [aws_kms_key](https://registry.terraform.io/providers/hashicorp/aws/3.10/docs/resources/kms_key) |
| [aws_partition](https://registry.terraform.io/providers/hashicorp/aws/3.10/docs/data-sources/partition) |
| [aws_security_group_rule](https://registry.terraform.io/providers/hashicorp/aws/3.10/docs/resources/security_group_rule) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| admin\_role\_groups | K8S RBAC group for the admin role | `list(string)` | <pre>[<br>  "system:masters"<br>]</pre> | no |
| admin\_role\_name | Kubernetes Admin role name, defaults to KubernetesAdmin | `string` | `"K8sAdmin"` | no |
| cluster\_enabled\_log\_types | A list of the desired control plane logging to enable. For more information, see Amazon EKS Control Plane Logging documentation (https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html) | `list(string)` | `[]` | no |
| cluster\_endpoint\_public\_access\_cidrs | List of CIDR blocks which can access the Amazon EKS public API server endpoint. | `list(string)` | `[]` | no |
| cluster\_log\_retention\_in\_days | Number of days to retain log events. Default retention - 30 days. | `number` | `30` | no |
| cluster\_name | Name of the EKS cluster. Also used as a prefix in names of related resources. | `string` | n/a | yes |
| cluster\_security\_group\_rules | Additional inbound/outbound rules for the cluster's primary security group | <pre>list(object({<br>    type        = string<br>    cidr_blocks = list(string)<br>    from_port   = string<br>    protocol    = string<br>    to_port     = string<br>    description = string<br>  }))</pre> | `[]` | no |
| cluster\_version | Kubernetes version to use for the EKS cluster. | `string` | `"1.19"` | no |
| create\_admin\_role | Whether to create admin role or not | `bool` | `true` | no |
| eks\_cluster\_iam\_role\_name | IAM role name for the cluster. | `string` | `"eks"` | no |
| enable\_secret\_encryption | Create a KMS key for encrypting Kubernetes secrets (for newly created clusters) | `bool` | `false` | no |
| environment | Environment, choose from staging or production | `string` | `""` | no |
| k8s\_tags | A map of tags to add to all resources. | `map(string)` | `{}` | no |
| manage\_aws\_auth | Whether to apply the aws-auth configmap file | `bool` | `true` | no |
| map\_accounts | Additional AWS account numbers to add to the aws-auth configmap. | `list(string)` | `[]` | no |
| map\_roles | Additional IAM roles to add to the aws-auth configmap. | <pre>list(object({<br>    rolearn  = string<br>    username = string<br>    groups   = list(string)<br>  }))</pre> | `[]` | no |
| map\_users | Additional IAM users to add to the aws-auth configmap. | <pre>list(object({<br>    userarn  = string<br>    username = string<br>    groups   = list(string)<br>  }))</pre> | `[]` | no |
| node\_groups | Map of map of node groups to create. See `node_groups` module's documentation for more details | `any` | `{}` | no |
| node\_groups\_defaults | Map of values to be applied to all node groups. See `node_groups` module's documentaton for more details | `any` | `{}` | no |
| region | AWS Region to be used | `string` | `"us-east-2"` | no |
| vpc\_cidr | The CIDR block for the VPC. | `string` | `""` | no |
| vpc\_id | vpc\_id have to be set | `string` | `""` | no |
| vpc\_name | Name to be used on all vpc resources as identifier | `string` | `""` | no |
| vpc\_private\_subnets\_ids | vpc\_private\_subnets\_ids have to be set | `list(string)` | `[]` | no |
| vpc\_public\_subnets\_ids | vpc\_private\_subnets\_ids have to be set | `list(string)` | `[]` | no |
| write\_kubeconfig | if set to true, this will write kubeconfig to file localy. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster\_endpoint | Endpoint for EKS control plane. |
| cluster\_security\_group\_id | Security group ids attached to the cluster control plane. |
| config\_map\_aws\_auth | A kubernetes configuration to authenticate to this EKS cluster. |
| eks\_cluster\_iam\_role\_arn | iam role arn or eks cluster |
| kubectl\_config | kubectl config as generated by the module. |
| node\_groups | Outputs from node groups |
| region | AWS region. |
| worker\_security\_group\_id | Security group ids attached to the cluster control plane. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
