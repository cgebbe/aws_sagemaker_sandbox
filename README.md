# About

This repository holds code to

- setup a AWS SageMaker environment using terraform
- notes to build a custom docker image

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

## push docker to ECR

Get access to a console with docker. Sagemaker studio by default does NOT provide docker, so these are possible alternatives:

- Cloudshell - easy but usually too little space for docker images :/
- EC2 - now included here!
- Sagemaker Notebook Classic
- Sagemaker Studio local mode, but seems a bit tricky to setup, see https://docs.aws.amazon.com/sagemaker/latest/dg/studio-updated-local.html

```bash
# install docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# install AWS CLI
sudo apt install -y unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# login to ECR registry (note the sudo!)
ECR_URL=... # get from terraform output
aws ecr get-login-password --region eu-west-1 | sudo docker login --username AWS --password-stdin $ECR_URL

# run docker image and check jupyter kernel
# IMAGE=pytorch/pytorch:2.4.1-cuda11.8-cudnn9-runtime # doesn't have Jupyter kernel
# NOTE: default sagemaker image has 3.10.14
IMAGE=jupyter/scipy-notebook:x86_64-python-3.11.6
sudo docker run --rm -it --entrypoint=bash $IMAGE
jupyter-kernelspec list
#   python3    /opt/conda/share/jupyter/kernels/python3

# tag and build docker
DST_IMAGE=$ECR_URL:20240917_v1
echo $DST_IMAGE
sudo docker tag $IMAGE $DST_IMAGE
sudo docker push $DST_IMAGE
```

# Import image into SageMaker studio classic (UI or CLI)

- see https://docs.aws.amazon.com/sagemaker/latest/dg/studio-byoi-create.html and following pages

As ApplicationType select `SageMaker studio classic` !

# Import image into SageMaker studio new (UI or CLI)

- follow https://docs.aws.amazon.com/sagemaker/latest/dg/studio-updated-migrate-lcc.html

As ApplicationType select e.g. `Jupyterlab image` !

# delete all created resources

- see https://github.com/rebuy-de/aws-nuke
