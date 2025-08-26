# IAM Role for EC2 Instance
resource "aws_iam_role" "instance" {
  name = "${var.environment}-ide-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = ["ec2.amazonaws.com", "ssm.amazonaws.com"]
        }
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "${var.environment}-ide-role"
  })
}

# Instance Profile
resource "aws_iam_instance_profile" "instance" {
  name = "${var.environment}-ide-profile"
  role = aws_iam_role.instance.name

  tags = merge(var.common_tags, {
    Name = "${var.environment}-ide-profile"
  })
}

# Attach SSM Managed Instance Core policy
resource "aws_iam_role_policy_attachment" "ssm_managed_instance_core" {
  role       = aws_iam_role.instance.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Custom policy for IDE functionality
resource "aws_iam_policy" "ide_custom" {
  name        = "${var.environment}-ide-custom-policy"
  description = "Custom policy for IDE instance"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecretVersionIds"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:ListSecrets"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "iam:CreateRole",
          "iam:GetRolePolicy",
          "iam:DetachRolePolicy",
          "iam:AttachRolePolicy",
          "iam:PutRolePolicy",
          "iam:DeleteRolePolicy",
          "iam:DeleteRole",
          "iam:ListInstanceProfilesForRole",
          "iam:ListAttachedRolePolicies",
          "iam:ListRolePolicies",
          "iam:TagRole",
          "iam:PassRole",
          "sts:AssumeRole",
          "iam:DeleteServiceLinkedRole",
          "iam:GetServiceLinkedRoleDeletionStatus"
        ]
        Resource = [
          "arn:aws:iam::*:role/eks-workshop*",
          "arn:aws:iam::*:role/eksctl-eks-workshop*",
          "arn:aws:iam::*:role/javascript-2d-game*",
          "arn:aws:iam::*:role/aws-service-role/fis*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "iam:CreatePolicy",
          "iam:DeletePolicy",
          "iam:GetPolicyVersion",
          "iam:DeletePolicyVersion",
          "iam:ListPolicyVersions",
          "iam:TagPolicy",
          "iam:GetPolicy"
        ]
        Resource = [
          "arn:aws:iam::*:policy/eks-workshop*",
          "arn:aws:iam::*:policy/eksctl-eks-workshop*",
          "arn:aws:iam::*:policy/javascript-2d-game*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "iam:CreateInstanceProfile",
          "iam:DeleteInstanceProfile",
          "iam:GetInstanceProfile",
          "iam:TagInstanceProfile",
          "iam:RemoveRoleFromInstanceProfile",
          "iam:AddRoleToInstanceProfile"
        ]
        Resource = [
          "arn:aws:iam::*:instance-profile/eks-workshop*",
          "arn:aws:iam::*:instance-profile/eksctl-eks-workshop*",
          "arn:aws:iam::*:instance-profile/javascript-2d-game*",
          "arn:aws:iam::*:instance-profile/eks-*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "iam:CreateUser",
          "iam:DeleteUser",
          "iam:TagUser",
          "iam:GetUser",
          "iam:ListGroupsForUser",
          "iam:AttachUserPolicy",
          "iam:DetachUserPolicy",
          "iam:ListAttachedUserPolicies",
          "iam:*SSHPublicKey"
        ]
        Resource = [
          "arn:aws:iam::*:user/eks-workshop*",
          "arn:aws:iam::*:user/javascript-2d-game*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "iam:ListOpenIDConnectProviders",
          "iam:CreateOpenIDConnectProvider",
          "iam:DeleteOpenIDConnectProvider",
          "iam:TagOpenIDConnectProvider",
          "iam:GetOpenIDConnectProvider",
          "iam:GetRole",
          "iam:ListPolicies",
          "iam:ListRoles"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "iam:CreateServiceLinkedRole"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "iam:AWSServiceName" = [
              "eks.amazonaws.com",
              "eks-nodegroup.amazonaws.com",
              "eks-fargate.amazonaws.com",
              "guardduty.amazonaws.com",
              "spot.amazonaws.com",
              "fis.amazonaws.com",
              "transitgateway.amazonaws.com",
              "elasticloadbalancing.amazonaws.com"
            ]
          }
        }
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "${var.environment}-ide-custom-policy"
  })
}

# Attach custom policy to role
resource "aws_iam_role_policy_attachment" "ide_custom" {
  role       = aws_iam_role.instance.name
  policy_arn = aws_iam_policy.ide_custom.arn
}

# EKS and EC2 permissions policy
resource "aws_iam_policy" "eks_ec2" {
  name        = "${var.environment}-eks-ec2-policy"
  description = "Policy for EKS and EC2 operations"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:*",
          "ec2:*",
          "iam:*",
          "ecr:*",
          "elasticloadbalancing:*",
          "autoscaling:*",
          "cloudwatch:*",
          "logs:*",
          "kms:*",
          "s3:*",
          "cloudformation:*"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "iam:CreateServiceLinkedRole"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "iam:AWSServiceName" = "eks.amazonaws.com"
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "iam:CreateServiceLinkedRole"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "iam:AWSServiceName" = "ec2scheduled.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "${var.environment}-eks-ec2-policy"
  })
}

# Attach EKS/EC2 policy to role
resource "aws_iam_role_policy_attachment" "eks_ec2" {
  role       = aws_iam_role.instance.name
  policy_arn = aws_iam_policy.eks_ec2.arn
}
