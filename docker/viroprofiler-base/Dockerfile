FROM mambaorg/micromamba:0.25.1

LABEL author="Jinlong Ru"

USER root

# Activate conda env during docker build
ARG MAMBA_DOCKERFILE_ACTIVATE=1
# Set PATH manually, because nextflow doesn't activate base env by default.
ENV PATH=/opt/conda/bin:/opt/conda/envs/viroprofiler-checkv/bin:/opt/conda/envs/viroprofiler-virsorter2/bin:$PATH
ENV CHECKVDB="/db/checkv-db-v1.2"

# Copy conda env files
COPY docker/viroprofiler-base/env_*.yml /tmp

# Install packages
RUN --mount=type=cache,target=/opt/conda/pkgs micromamba install -n base -f /tmp/env_base.yml -y
RUN --mount=type=cache,target=/opt/conda/pkgs micromamba create -f /tmp/env_checkv.yml -y
RUN --mount=type=cache,target=/opt/conda/pkgs micromamba create -f /tmp/env_virsorter2.yml -y

# clean
RUN micromamba clean --all --yes
