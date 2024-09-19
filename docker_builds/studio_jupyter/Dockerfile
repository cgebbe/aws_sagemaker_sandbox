# NOTE: use 2023 image to get python3.9 instead of python3.7
# FROM public.ecr.aws/amazonlinux/amazonlinux:2
FROM public.ecr.aws/amazonlinux/amazonlinux:2023

ARG NB_USER="sagemaker-user"
ARG NB_UID="1000"
ARG NB_GID="100"

RUN yum install --assumeyes python3-pip shadow-utils && \
    useradd --create-home --shell /bin/bash --gid "${NB_GID}" --uid ${NB_UID} ${NB_USER} && \
    yum clean all && \
    pip install jupyterlab

# RUN python3 -m pip install --upgrade pip

# RUN python3 -m pip install --upgrade urllib3==1.26.6

# NOTE: add amazon-sagemaker-jupyter-scheduler to get notebook job button
RUN pip install amazon-sagemaker-jupyter-scheduler

# NOTE: sagemaker-training doesn't have a wheel :/
# Better alternative might be uv setup?!
RUN yum install --assumeyes gcc python3-devel python3-setuptools python3-pip-wheel python3-wheel
RUN pip install sagemaker-training
RUN pip install sagemaker
RUN pip install sagemaker-headless-execution-driver

# install sudo
RUN yum install --assumeyes sudo which
RUN echo "${NB_USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
ENV USER=$NB_USER

WORKDIR "/home/${NB_USER}"

# add python
RUN ln -s /usr/bin/python3 /usr/bin/python

RUN pip install sagemaker-kernel-wrapper

USER ${NB_UID}
CMD jupyter lab --ip 0.0.0.0 --port 8888 \
  --ServerApp.base_url="/jupyterlab/default" \
  --ServerApp.token='' \
  --ServerApp.allow_origin='*'