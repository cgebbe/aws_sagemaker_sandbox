# see https://registry.terraform.io/modules/terraform-aws-modules/ecr/aws/latest
module "ecr" {
  source = "terraform-aws-modules/ecr/aws"

  repository_name = "private-example"

#   repository_read_write_access_arns = ["arn:aws:iam::012345678901:role/terraform"]
  repository_read_write_access_arns = [aws_iam_role.sagemaker_execution_role.arn]
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 30 images",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["v"],
          countType     = "imageCountMoreThan",
          countNumber   = 30
        },
        action = {
          type = "expire"
        }
      }
    ]
  })

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}