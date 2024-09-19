# NOTE: use 2023 image to get python3.9 instead of python3.7
# FROM public.ecr.aws/amazonlinux/amazonlinux:2
FROM public.ecr.aws/amazonlinux/amazonlinux:2023

# setup user
ARG NB_USER="sagemaker-user"
ARG NB_UID="1000"
ARG NB_GID="100"
RUN yum install --assumeyes \
  shadow-utils \
  && useradd --create-home --shell /bin/bash --gid "${NB_GID}" --uid ${NB_UID} ${NB_USER}

# install required stuff
RUN yum install --assumeyes \
  sudo \
  which \
  gcc \
  python3-pip \
  python3-devel \
  python3-setuptools \
  python3-pip-wheel \
  python3-wheel \
  && yum clean all

# NOTE: sagemaker packages are only required for Jupyter notebook jobs
RUN pip install jupyterlab \
  amazon-sagemaker-jupyter-scheduler \
  sagemaker \
  sagemaker-training \
  sagemaker-headless-execution-driver \
  sagemaker-kernel-wrapper

# add python (not just python3)
RUN ln -s /usr/bin/python3 /usr/bin/python

# setup empty sudo password
RUN echo "${NB_USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# setup env variables
ENV SM_KERNEL_NAME=python3
ENV USER=$NB_USER
USER ${NB_UID}
WORKDIR "/home/${NB_USER}"

# start jupyter lab
CMD jupyter lab --ip 0.0.0.0 --port 8888 \
  --ServerApp.base_url="/jupyterlab/default" \
  --ServerApp.token='' \
  --ServerApp.allow_origin='*'