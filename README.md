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

## build and check docker image

```bash
# build docker...
cd /path/to/Dockerfile
IMAGE=studio-jupyter-v0
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

# login to ECR registry
ECR_URL=561130499334.dkr.ecr.eu-west-1.amazonaws.com/private-example # get from terraform output
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

# Notes

## Brief history of SM studio

- In 2017 SM
- In 2019 SM notebook instances
- Around 01/2020 ?!, SM studio, see https://docs.aws.amazon.com/sagemaker/latest/dg/notebooks-comparison.html
- In 11/2023, a _new_ SM studio was introduced and the old one was renamed to SM Studio Classic, see https://docs.aws.amazon.com/sagemaker/latest/dg/studio-updated.html

## Difference between Studio classic and new Studio

from https://docs.aws.amazon.com/sagemaker/latest/dg/studio-updated-migrate-lcc.html

> Amazon SageMaker Studio Classic operates in a split environment with:
>
> - A JupyterServer application running the Jupyter Server.
> - Studio Classic notebooks running on one or more KernelGateway applications
>
> Studio has shifted away from a split environment. Studio runs the JupyterLab and Code Editor, based on Code-OSS, Visual Studio Code - Open Source applications in a local runtime model.  
> Your existing Studio Classic custom images may not work in Studio.

from https://aws.amazon.com/blogs/machine-learning/boost-productivity-on-amazon-sagemaker-studio-introducing-jupyterlab-spaces-and-generative-ai-tools/

> In summary, we have transitioned towards a localized architecture. In this new setup, Jupyter server and kernel processes operate alongside in a single Docker container, hosted on the same ML compute instance.
> SageMaker Studio has transitioned to a local run model, moving away from the previous split model where code was stored on an EFS mount and run remotely on an ML instance via remote Kernel Gateway.
> [In Studio Classic] Users access their individual user profile through a dedicated Jupyter Server app, connected via HTTPS/WSS in their web browser. SageMaker Studio Classic uses a remote kernel architecture using a combination of Jupyter Server and Kernel Gateway app types, enabling notebook servers to interact with kernels on remote hosts

This means

- Studio Classic notebooks only needs to provide jupyter kernel, but NOT the Jupyter app.
- Studio notebooks need to provide full jupyter app (including AWS specific packages for Jupyter notebook jobs) and/or VSCode server

For us,

## Image requirements from Studio Classic

- see https://docs.aws.amazon.com/sagemaker/latest/dg/studio-byoi-specs.html

```Dockerfile
# only ipykernel!
FROM public.ecr.aws/amazonlinux/amazonlinux:2

ARG NB_USER="sagemaker-user"
ARG NB_UID="1000"
ARG NB_GID="100"

RUN \
    yum install --assumeyes python3 shadow-utils && \
    useradd --create-home --shell /bin/bash --gid "${NB_GID}" --uid ${NB_UID} ${NB_USER} && \
    yum clean all && \
    python3 -m pip install ipykernel && \
    python3 -m ipykernel install

USER ${NB_UID}
```

## Image requirements from (new) Studio

- for JupyterLab
  - https://docs.aws.amazon.com/sagemaker/latest/dg/studio-updated-jl-image-specifications.html
- for VSCode
  - https://docs.aws.amazon.com/sagemaker/latest/dg/code-editor-custom-images-specifications.html
- for RStudio
  - https://docs.aws.amazon.com/sagemaker/latest/dg/rstudio-byoi-specs.html

```Dockerfile
# not only ipykernel, but full jupyterlab!
FROM public.ecr.aws/amazonlinux/amazonlinux:2

ARG NB_USER="sagemaker-user"
ARG NB_UID="1000"
ARG NB_GID="100"
RUN yum install --assumeyes python3 shadow-utils && \
    useradd --create-home --shell /bin/bash --gid "${NB_GID}" --uid ${NB_UID} ${NB_USER} && \
    yum clean all && \
    python3 -m pip install jupyterlab

RUN python3 -m pip install --upgrade pip

RUN python3 -m pip install --upgrade urllib3==1.26.6

USER ${NB_UID}
CMD jupyter lab --ip 0.0.0.0 --port 8888 \
  --ServerApp.base_url="/jupyterlab/default" \
  --ServerApp.token='' \
  --ServerApp.allow_origin='*'
```
