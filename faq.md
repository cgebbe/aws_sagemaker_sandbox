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

See minimal Dockerfile below and Dockerfile of default image at https://github.com/aws/sagemaker-distribution/blob/f4f15e79668b4af0b5203b3704c6478c04f89d60/template/v2/Dockerfile

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

When using default SM image, we have notebook job feature and these packages

```bash
amazon-q-developer-jupyterlab-ext       3.2.0
amazon_sagemaker_jupyter_ai_q_developer 1.0.7
amazon_sagemaker_jupyter_scheduler      3.1.2
hdijupyterutils                         0.21.0
jupyter                                 1.0.0
jupyter_ai                              2.20.0
jupyter_ai_magics                       2.20.0
jupyter_client                          8.6.2
jupyter_collaboration                   1.1.0
jupyter-console                         6.6.3
jupyter_core                            5.7.2
jupyter-dash                            0.4.2
jupyter-events                          0.6.3
jupyter-lsp                             2.2.5
jupyter_scheduler                       2.7.1
jupyter_server                          2.10.0
jupyter_server_fileid                   0.9.2
jupyter-server-mathjax                  0.2.6
jupyter_server_proxy                    4.3.0
jupyter_server_terminals                0.5.3
jupyter-ydoc                            1.1.1
jupyterlab                              4.1.6
jupyterlab_git                          0.50.1
jupyterlab-lsp                          5.0.3
jupyterlab_pygments                     0.3.0
jupyterlab_server                       2.24.0
jupyterlab_widgets                      3.0.11
sagemaker-jupyterlab-emr-extension      0.3.2
sagemaker-jupyterlab-extension          0.3.2
sagemaker-jupyterlab-extension-common   0.1.19
```

When using custom images, do we have notebook feature?

- No, doesn't seem to be the case.

When addding `pip install amazon-sagemaker-jupyter-scheduler`

- we have notebook job button, but Additional Option error `Unexpected token '<', "<!DOCTYPE "... is not valid JSON`
- -> maybe beause I installed a very old version? (2.2.19 instead of 3.1.2?!)

When using amazon-linux/2023 docker image with newer package versions

- could at least install newer jupyter-scheduler version and python3.9
- get notebook job button and can start, but notebook fails with error `exec amazon_sagemaker_scheduler failed: No such file or directory`
- -> `pip install sagemaker-training` from https://github.com/aws/sagemaker-python-sdk/issues/4113

When adding `sagemaker-training`

- WARNING: sagemaker training limits protobuf, might conflict!
  - see https://github.com/aws/sagemaker-training-toolkit/blob/master/setup.py
- still same error :/

When adding `WORKDIR`

- same error

When adding `pip install sagemaker` based on https://github.com/aws/sagemaker-python-sdk/pull/4270/files

- same error

Do I need to downgrade `amazon-sagemaker-jupyter-scheduler to 2.*` ?!

- Sources
  - https://stackoverflow.com/q/78333128
  - https://stackoverflow.com/a/78363355
- check against official docker `docker run --rm -it --entrypoint=bash public.ecr.aws/sagemaker/sagemaker-distribution:1.10.1-cpu`
  - there, we have a `amazon_sagemaker_scheduler` as CLI. Why not installed above?!
  - Ah, because it's in `sagemaker_headless_execution`... -> add that
- P: `amazon_sagemaker_scheduler` requires sudo, docker image doesn't have it
  - S: add it based on template SM Dockerfile https://github.com/aws/sagemaker-distribution/blob/main/template/v2/Dockerfile
- Result
  - ...

```bash
# sagemaker packages in bash public.ecr.aws/sagemaker/sagemaker-distribution:1.10.1-cpu
amazon_sagemaker_jupyter_ai_q_developer 1.0.9
amazon_sagemaker_jupyter_scheduler      3.1.5
amazon-sagemaker-sql-editor             0.1.11
amazon-sagemaker-sql-execution          0.1.6
amazon-sagemaker-sql-magic              0.1.3
sagemaker                               2.227.0
sagemaker-headless-execution-driver     0.0.13
sagemaker-jupyterlab-emr-extension      0.3.3
sagemaker-jupyterlab-extension          0.3.2  # some improvements
sagemaker-jupyterlab-extension-common   0.1.21
sagemaker-kernel-wrapper                0.0.4
sagemaker-studio-analytics-extension    0.1.2
sagemaker-studio-sparkmagic-lib         0.1.4
```

Next Problem: `which` command not found :/

- ...

# Using the Classic Studio jupyter lab...

When using custom images, do we have notebook feature?

- NOTE: After attaching image, need to stop and start space again!
- job button visible
- when click job button, some issue with additional options, so likely here also some service missing
