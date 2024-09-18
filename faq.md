# FAQ

# How has SageMaker (SM) studio developed?

- In 2017 SM
- In 2019 SM notebook instances
- Around 01/2020 ?!, SM studio, see https://docs.aws.amazon.com/sagemaker/latest/dg/notebooks-comparison.html
- In 11/2023, a _new_ SM studio was introduced and the old one was renamed to SM Studio Classic, see https://docs.aws.amazon.com/sagemaker/latest/dg/studio-updated.html

# How does new Studio differ from Studio Classic?

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

# What image requirements from Studio Classic?

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

# What image requirements from (new) Studio?

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

# Using the new Studio jupyter lab...

When using custom images, do we have notebook feature?

- No, doesn't seem to be the case.
- Likely need to `pip install amazon-sagemaker-jupyter-scheduler`, maybe more?!
- hmm... but also not with default image?! Likely need to install more https://docs.aws.amazon.com/sagemaker/latest/dg/scheduled-notebook-installation.html

# Using the Classic Studio jupyter lab...

When using custom images, do we have notebook feature?

- NOTE: After attaching image, need to stop and start space again!
- job button visible
- when click job button, some issue with additional options, so likely here also some service missing
