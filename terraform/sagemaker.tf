# domain
# see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sagemaker_domain
resource "aws_sagemaker_domain" "example" {
  domain_name = "dev"
  auth_mode   = "IAM"
  vpc_id      = module.vpc.vpc_id
  subnet_ids  = module.vpc.private_subnets

  default_space_settings {
    execution_role = aws_iam_role.sagemaker_execution_role.arn
  }

  default_user_settings {
    execution_role = aws_iam_role.sagemaker_execution_role.arn
    # `app:JupyterServer:` for classic studio, `studio::` for studio
    default_landing_uri = "studio::"
    studio_web_portal = "ENABLED"
  }
}

# user profile
# see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sagemaker_user_profile
resource "aws_sagemaker_user_profile" "example" {
  domain_id         = aws_sagemaker_domain.example.id
  user_profile_name = "my-sagemaker-profile"
}


# space
# NOTE: this seems to create collab studio classic space
# instead of personal new studio space?!  
# resource "aws_sagemaker_space" "example" {
#   domain_id  = aws_sagemaker_domain.example.id
#   space_name = "example"
# }

# app - need to specify storage details for JupyterLab ?!
# resource "aws_sagemaker_app" "example" {
#   domain_id         = aws_sagemaker_domain.example.id
#   # user_profile_name = aws_sagemaker_user_profile.example.user_profile_name
#   space_name = aws_sagemaker_space.example.space_name
#   app_name          = "default"
#   app_type          = "JupyterLab"
#   resource_spec   {
#     # see https://docs.aws.amazon.com/sagemaker/latest/dg/notebooks-available-instance-types.html
#     instance_type = "ml.t3.medium"
#     # sagemaker_image_arn = ...
#   }
# }
