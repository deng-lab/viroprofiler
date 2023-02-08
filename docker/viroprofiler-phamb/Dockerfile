FROM mambaorg/micromamba:0.25.1

LABEL author="Jinlong Ru"

USER root

ARG MAMBA_DOCKERFILE_ACTIVATE=1
ENV PATH=/opt/conda/bin:$PATH

COPY ./docker/viroprofiler-phamb/env_*.yml /tmp

# Install packages into `base` env, because nextflow can't use other envs.
# Phamb is installed in `base` env.
RUN --mount=type=cache,target=/opt/conda/pkgs micromamba install -n base -f /tmp/env_phamb.yml -y

RUN micromamba clean --all --yes
