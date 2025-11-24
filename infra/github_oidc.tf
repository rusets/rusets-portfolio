############################################
# GitHub OIDC provider (existing shared)
############################################

data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

############################################
# IAM policy for GitHub Actions (S3 + CloudFront)
############################################

resource "aws_iam_policy" "github_actions" {
  name        = "rusets-portfolio-gha-policy"
  description = "Permissions for GitHub Actions to deploy static site to S3 and invalidate CloudFront cache"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:GetObject",
          "s3:DeleteObject"
        ],
        Resource = [
          "${aws_s3_bucket.site.arn}/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket"
        ],
        Resource = aws_s3_bucket.site.arn
      },
      {
        Effect = "Allow",
        Action = [
          "cloudfront:CreateInvalidation"
        ],
        Resource = "*"
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
############################################

resource "aws_iam_role_policy_attachment" "github_actions" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions.arn
}
