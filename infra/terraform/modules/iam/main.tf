# fetch aws account id
data "aws_caller_identity" "current" {}

# trust policy - allows only the LBC service account to assume this role
data "aws_iam_policy_document" "lbc_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "${var.oidc_provider_url}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.oidc_provider_url}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

# IAM role for AWS Load Balancer Controller
resource "aws_iam_role" "lbc" {
  name               = "${var.project_name}-${var.environment}-lbc-role"
  assume_role_policy = data.aws_iam_policy_document.lbc_assume_role.json

  tags = var.tags
}

# IAM policy for AWS Load Balancer Controller
resource "aws_iam_policy" "lbc_policy" {
    name        = "${var.project_name}-${var.environment}-lbc-policy"
    description = "IAM policy for AWS Load Balancer Controller"
    policy      = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
          "elasticloadbalancing:*",
          "ec2:Describe*",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:CreateSecurityGroup",
          "ec2:DeleteSecurityGroup",
          "ec2:CreateTags",
          "ec2:DeleteTags",
          "cognito-idp:DescribeUserPoolClient",
          "acm:ListCertificates",
          "acm:DescribeCertificate",
          "iam:ListServerCertificates",
          "iam:GetServerCertificate",
          "waf-regional:GetWebACL",
          "waf-regional:AssociateWebACL",
          "waf-regional:DisassociateWebACL",
          "wafv2:GetWebACL",
          "wafv2:AssociateWebACL",
          "wafv2:DisassociateWebACL",
          "shield:GetSubscriptionState",
          "shield:DescribeProtection",
          "shield:CreateProtection",
          "shield:DeleteProtection"
          ]
          Resource = "*"
        }
      ]
    })
    
    tags = var.tags
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "lbc_attach" {
    policy_arn = aws_iam_policy.lbc_policy.arn
    role       = aws_iam_role.lbc.name
}