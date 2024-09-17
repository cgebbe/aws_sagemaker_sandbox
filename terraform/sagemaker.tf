# sagemaker domain
# see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sagemaker_domain
resource "aws_sagemaker_domain" "example" {
  domain_name = "dev"
  auth_mode   = "IAM"
  vpc_id      = module.vpc.vpc_id
  subnet_ids  = module.vpc.private_subnets

#   default_space_settings {
#   }

  default_user_settings {
    execution_role = aws_iam_role.sagemaker_execution_role.arn
    default_landing_uri = "studio::"
    studio_web_portal = "ENABLED"
  }
}


# sagemaker user profile
# see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sagemaker_user_profile

resource "aws_sagemaker_user_profile" "example" {
  domain_id         = aws_sagemaker_domain.example.id
  user_profile_name = "my-sagemaker-profile"
}
