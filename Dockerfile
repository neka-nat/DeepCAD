FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu22.04

RUN apt-get update && apt-get install -y \
    sudo \
    wget \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    sh Miniconda3-latest-Linux-x86_64.sh -b -p /opt/miniconda3 && \
    rm -r Miniconda3-latest-Linux-x86_64.sh

ENV PATH /opt/miniconda3/bin:$PATH
ENV PIP_ROOT_USER_ACTION=ignore

RUN conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main && \
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r

RUN pip install --upgrade pip && \
    conda update -n base -c defaults conda && \
    conda create -n deepcad python=3.10 -y && \
    conda init && \
    echo "conda activate deepcad" >> ~/.bashrc

ENV CONDA_DEFAULT_ENV deepcad && \
    PATH /opt/conda/envs/deepcad/bin:$PATH

SHELL ["conda", "run", "-n", "deepcad", "/bin/bash", "-c"]

COPY requirements.txt .

RUN pip install -r requirements.txt && \
    conda install -c conda-forge pythonocc-core=7.5.1

COPY . .

CMD ["conda", "activate", "deepcad"]
