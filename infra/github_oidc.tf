############################################
# GitHub OIDC provider (existing shared)
# Purpose: Reuse global GitHub OIDC provider
############################################

data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

############################################
# IAM policy for GitHub Actions
# Purpose: Deploy static site + manage TF backend + read infra
############################################

resource "aws_iam_policy" "github_actions" {
  name        = "rusets-portfolio-gha-policy"
  description = "Permissions for GitHub Actions to deploy static site and manage Terraform backend state"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      # --- Static site S3 objects ---
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:GetObject",
          "s3:DeleteObject",
        ],
        Resource = [
          "${aws_s3_bucket.site.arn}/*",
        ],
      },

      # --- Static site bucket list + policy manage ---
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket",
        ],
        Resource = aws_s3_bucket.site.arn,
      },
      {
        Effect = "Allow",
        Action = [
          "s3:GetBucketPolicy",
          "s3:PutBucketPolicy",
        ],
        Resource = aws_s3_bucket.site.arn,
      },

      # --- CloudFront invalidation + manage distribution/OAC ---
      {
        Effect = "Allow",
        Action = [
          "cloudfront:CreateInvalidation",
        ],
        Resource = "*",
      },
      {
        Effect = "Allow",
        Action = [
          "cloudfront:GetDistribution",
          "cloudfront:GetDistributionConfig",
          "cloudfront:UpdateDistribution",
          "cloudfront:ListDistributions",
          "cloudfront:GetOriginAccessControl",
          "cloudfront:ListOriginAccessControls",
        ],
        Resource = "*",
      },

      # --- Terraform backend (S3 state) ---
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
        ],
        Resource = [
          "arn:aws:s3:::tf-state-rusets-portfolio/rusets-portfolio/terraform.tfstate",
        ],
      },
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket",
        ],
        Resource = "arn:aws:s3:::tf-state-rusets-portfolio",
      },

      # --- Terraform backend (DynamoDB locks) ---
      {
        Effect = "Allow",
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:UpdateItem",
          "dynamodb:DescribeTable",
        ],
        Resource = "arn:aws:dynamodb:us-east-1:097635932419:table/tf-locks-rusets-portfolio",
      },

      # --- Route53 zone read (for aws_route53_zone.this) ---
      {
        Effect = "Allow",
        Action = [
          "route53:GetHostedZone",
          "route53:ListHostedZones",
        ],
        Resource = "*",
      },

      # --- IAM OIDC provider read (data.aws_iam_openid_connect_provider.github) ---
      {
        Effect = "Allow",
        Action = [
          "iam:ListOpenIDConnectProviders",
          "iam:GetOpenIDConnectProvider",
        ],
        Resource = "*",
      },

      # --- ACM certificate read (for aws_acm_certificate.site) ---
      {
        Effect = "Allow",
        Action = [
          "acm:DescribeCertificate",
          "acm:ListCertificates",
          "acm:GetCertificate",
        ],
        Resource = "*",
      }
    ]
  })

  tags = {
    Project = "rusets-portfolio"
    Owner   = "Ruslan AWS"
  }
}

############################################
# IAM role for GitHub Actions (rusets-portfolio)
# Purpose: Allow GitHub OIDC to assume limited deploy role
############################################

resource "aws_iam_role" "github_actions" {
  name = "rusets-portfolio-gha-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = data.aws_iam_openid_connect_provider.github.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          },
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:rusets/rusets-portfolio:*"
          }
        }
      }
    ]
  })

  tags = {
    Project = "rusets-portfolio"
    Owner   = "Ruslan AWS"
  }
}

############################################
# Attach policy to GitHub Actions role
# Purpose: Bind least-privilege policy to deploy role
############################################

resource "aws_iam_role_policy_attachment" "github_actions" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions.arn
}

############################################
# Temporary admin policy for CI debugging
# Purpose: Grant full admin to GitHub Actions role (REMOVE LATER)
############################################

resource "aws_iam_role_policy_attachment" "github_actions_admin_temp" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
