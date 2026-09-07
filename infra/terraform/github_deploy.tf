# Reuse the existing account-wide provider without managing or changing it.
data "aws_iam_openid_connect_provider" "github" {
  arn = "arn:aws:iam::387344700059:oidc-provider/token.actions.githubusercontent.com"
}

locals {
  # Exact keys only: new website files require an explicit policy review.
  github_deploy_object_keys = [
    "index.html",
    "404.html",
    "pages/about.html",
    "pages/experience.html",
    "pages/resume.html",
    "pages/skills.html",
    "pages/projects.html",
    "pages/learning.html",
    "pages/articles.html",
    "pages/contact.html",
    "css/styles.css",
    "js/main.js",
    "images/andy-hopla.jpg",
    "favicon.ico",
    "favicon.svg",
  ]
}

resource "aws_iam_role" "github_deploy" {
  name                 = "andyhopla-production-content-deploy"
  description          = "Deploy approved portfolio content from Orky63/andyhopla.com main"
  max_session_duration = 3600
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = data.aws_iam_openid_connect_provider.github.arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          "token.actions.githubusercontent.com:sub" = "repo:Orky63/andyhopla.com:ref:refs/heads/main"
        }
      }
    }]
  })
}

resource "aws_iam_policy" "github_deploy" {
  name        = "andyhopla-production-content-deploy"
  description = "Read/write only approved website keys and invalidate the production distribution"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "ApprovedWebsiteObjectsOnly"
        Effect   = "Allow"
        Action   = ["s3:PutObject", "s3:GetObject"]
        Resource = [for key in local.github_deploy_object_keys : "${aws_s3_bucket.content.arn}/${key}"]
      },
      {
        Sid      = "ProductionInvalidationOnly"
        Effect   = "Allow"
        Action   = ["cloudfront:CreateInvalidation", "cloudfront:GetInvalidation"]
        Resource = aws_cloudfront_distribution.site.arn
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_deploy" {
  role       = aws_iam_role.github_deploy.name
  policy_arn = aws_iam_policy.github_deploy.arn
}
