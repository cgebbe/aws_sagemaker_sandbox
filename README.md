# About

This repository holds code to

- setup a AWS SageMaker environment using terraform
- notes to build a custom docker image

# Instructions

## setup sagemaker

```bash
# setup resources
cd terraform
terraform init
terraform apply

# P: sets up "Sagemaker studio classic" by default (not sure whether changeable with terraform)
# S: go to AWS console and MANUALLY "migrate" to new studio

# in UI:
```

## push docker to ECR

Get access to a console with docker. Sagemaker studio by default does NOT provide docker, so these are possible alternatives:

- EC2
- Cloudshell (usually too little space)
- Sagemaker Notebook Classic
- Sagemaker Studio local mode, see https://docs.aws.amazon.com/sagemaker/latest/dg/studio-updated-local.html

```bash
# enable docker access
DOMAIN_ID=d-yvzkfjpbxwx1
REGION=eu-west-1
aws --region $REGION sagemaker update-domain --domain-id $DOMAIN_ID --domain-settings-for-update '{"DockerSettings": {"EnableDockerAccess": "ENABLED"}}'
```

```bash
# login to ECR registry (get command from AWS UI)
aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin ...

# build doocker
```

# Alternative: build docker

- see requirements for docker at https://docs.aws.amazon.com/sagemaker/latest/dg/studio-updated-jl-image-specifications.html

# "import" docker image to SageMaker

- see https://stackoverflow.com/questions/75617926/failed-to-launch-app-from-custom-sagemaker-image-resourcenotfounderror-with-uid
