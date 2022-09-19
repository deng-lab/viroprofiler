FROM mambaorg/micromamba:0.25.1

LABEL author="Jinlong Ru"

USER root

# Activate conda env during docker build
ARG MAMBA_DOCKERFILE_ACTIVATE=1
# Set PATH manually, because nextflow doesn't activate base env by default.
ENV PATH=/opt/conda/bin:/opt/conda/envs/viroprofiler-emapper/bin:/opt/conda/envs/viroprofiler-abricate/bin:$PATH

COPY ./docker/viroprofiler-geneannot/env_*.yml /tmp

# install DRAM to `base` env
RUN --mount=type=cache,target=/opt/conda/pkgs micromamba install -n base -f /tmp/env_dram.yml -y
COPY ./docker/viroprofiler-geneannot/database_handler.py /opt/conda/lib/python3.10/site-packages/mag_annotator

# Install emapper to `viroprofiler_emapper` env
RUN --mount=type=cache,target=/opt/conda/pkgs micromamba create -f /tmp/env_emapper.yml -y

# Installl abricate to `viroprofiler_abricate` env
RUN --mount=type=cache,target=/opt/conda/pkgs micromamba create -f /tmp/env_abricate.yml -y

RUN micromamba clean --all --yes
