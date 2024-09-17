# role to access sagemaker
# (used chatGPTs)
resource "aws_iam_role" "sagemaker_execution_role" {
  name = "my-sagemaker-role2"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = {
          Service = [
          "sagemaker.amazonaws.com",
          "ec2.amazonaws.com",
          ]
        },
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "sagemaker_policy" {
  name        = "SageMakerFullAccessPolicy"
  description = "Policy to allow all SageMaker related actions"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "sagemaker:*",  # Allows all SageMaker actions
          "s3:*",         # Optional: Access to S3 for input/output
          "ecr:*",        # Optional: Access to Elastic Container Registry (ECR)
          "cloudwatch:*", # Optional: CloudWatch for logs/metrics
          "logs:*",
          "iam:PassRole"  # Allows SageMaker to pass roles
        ],
        Resource = "*"
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "attach_sagemaker_policy" {
  role       = aws_iam_role.sagemaker_execution_role.name
  policy_arn = aws_iam_policy.sagemaker_policy.arn
}