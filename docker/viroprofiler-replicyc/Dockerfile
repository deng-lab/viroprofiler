FROM mambaorg/micromamba:0.25.1

LABEL author="Jinlong Ru"

USER root

# Activate conda env during docker build
ARG MAMBA_DOCKERFILE_ACTIVATE=1
ENV PATH=/opt/conda/bin:/opt/conda/envs/viroprofiler-bacphlip/bin:$PATH

COPY docker/viroprofiler-replicyc/env_*.yml /tmp

# Install packages into `base` env
RUN --mount=type=cache,target=/opt/conda/pkgs micromamba install -n base -f /tmp/env_replidec.yml -y
RUN cd /opt/conda/lib/python3.10/site-packages/Replidec && \
    wget https://zenodo.org/record/6975142/files/db_v0.2.3.tar.gz && \
    tar xzf db_v0.2.3.tar.gz && \
    rm db_v0.2.3.tar.gz

# Install bacphlip to `viroprofiler_bacphlip` env
RUN --mount=type=cache,target=/opt/conda/pkgs micromamba create -f /tmp/env_bacphlip.yml -y

RUN micromamba clean --all --yes
