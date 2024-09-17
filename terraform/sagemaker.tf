# sagemaker domain
# see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sagemaker_domain

data "aws_iam_policy_document" "example" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["sagemaker.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "my-sagemaker-role" {
  name               = "my-sagemaker-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.example.json
}

resource "aws_sagemaker_domain" "example" {
  domain_name = "dev"
  auth_mode   = "IAM"
  vpc_id      = module.vpc.vpc_id
  subnet_ids  = module.vpc.private_subnets

  default_user_settings {
    execution_role = aws_iam_role.my-sagemaker-role.arn
  }
}


# sagemaker user profile
# see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sagemaker_user_profile

resource "aws_sagemaker_user_profile" "example" {
  domain_id         = aws_sagemaker_domain.example.id
  user_profile_name = "my-sagemaker-profile"
}
