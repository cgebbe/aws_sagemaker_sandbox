# About

This repository holds...

- terraform code to setup a AWS SageMaker environment using terraform
- instructions to build a custom docker image

# Instructions

## setup sagemaker (with required VPC), ECR and EC2

```bash
# setup resources
cd terraform
terraform init
terraform apply

# P: sets up "Sagemaker studio classic" by default (not sure whether changeable with terraform)
# S: go to AWS console and MANUALLY "migrate" to new studio

# in UI: create a new project
```

## setup sagemaker jobs

- https://docs.aws.amazon.com/sagemaker/latest/dg/scheduled-notebook-installation.html
  - now in the terraform code which is applied above, works!
- https://docs.aws.amazon.com/sagemaker/latest/dg/notebook-auto-run-constraints.html
  - lists requirements for docker image
- https://aws.amazon.com/sagemaker/pricing/
  - price per available instances
  - use `ml.t3.large` or `ml.t3.medium` are cheapest, but not available
  - `ml.m5.large` only 0.128 USD and available 30x

## build and check docker image

```bash
# build docker...
cd /path/to/Dockerfile
IMAGE=studio-jupyter-v3-with-sagemaker-training
docker build -t $IMAGE .

# ...or use existing
IMAGE=jupyter/scipy-notebook:x86_64-python-3.11.6

# check name of jupyter kernel (required when attaching in SM!)
docker run --rm -it --entrypoint=bash $IMAGE
jupyter-kernelspec list
#   python3    /opt/conda/share/jupyter/kernels/python3  for jupyter/scipy
#   python3    /usr/local/share/jupyter/kernels/python3  for built docker
```

## push docker image to ECR

Get access to a console with docker. Sagemaker studio by default does NOT provide docker, so these are possible alternatives:

- from your local computer
- Cloudshell - easy but usually too little space for docker images :/
- EC2 in account - now included in terraform code!
- Sagemaker Notebook Classic
- Sagemaker Studio local mode, but seems a bit tricky to setup, see https://docs.aws.amazon.com/sagemaker/latest/dg/studio-updated-local.html

```bash
# install docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
# TODO: add docker to usergroup

# install AWS CLI
sudo apt install -y unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# login to ECR registry (get URL from terraform output)
ECR_URL=561130499334.dkr.ecr.eu-west-1.amazonaws.com/private-example
aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin $ECR_URL

# tag and build docker
DST_IMAGE=$ECR_URL:$IMAGE
echo $DST_IMAGE
docker tag $IMAGE $DST_IMAGE
docker push $DST_IMAGE
```

## Import image into SageMaker studio classic (UI or CLI)

- see https://docs.aws.amazon.com/sagemaker/latest/dg/studio-byoi-create.html and following pages

As ApplicationType select `SageMaker studio classic` !

## Import image into SageMaker studio new (UI or CLI)

- follow https://docs.aws.amazon.com/sagemaker/latest/dg/studio-updated-migrate-lcc.html

As ApplicationType select e.g. `Jupyterlab image` !

## delete all created resources

- see https://github.com/rebuy-de/aws-nuke
