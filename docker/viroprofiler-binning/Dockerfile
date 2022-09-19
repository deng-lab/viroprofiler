FROM mambaorg/micromamba:0.25.1

LABEL author="Jinlong Ru"

USER root

ARG MAMBA_DOCKERFILE_ACTIVATE=1
ENV PATH=/opt/conda/bin:/opt/conda/envs/viroprofiler-dvf/bin:$PATH

COPY docker/viroprofiler-binning/env_*.yml /tmp

# Install packages into `base` env, because nextflow can't use other envs.
# Phamb is installed in `base` env.
RUN --mount=type=cache,target=/opt/conda/pkgs micromamba install -n base -f /tmp/env_binning.yml -y
RUN pip install https://github.com/RasmussenLab/vamb/archive/v3.0.8.zip
RUN cd /opt && \
    git clone https://github.com/RasmussenLab/phamb.git && \
    cd /opt/conda/bin && \
    ln -s /opt/phamb/workflows/mag_annotation/scripts/* .

# DeepVirFinder is installed in `viroprofiler_dvf` env.
RUN --mount=type=cache,target=/opt/conda/pkgs micromamba create -f /tmp/env_dvf.yml -y

# vRhyme is installed in `viroprofiler_vrhyme` env.
# RUN --mount=type=cache,target=/opt/conda/pkgs micromamba create -f /tmp/env_vrhyme.yml -y
RUN wget "https://github.com/AnantharamanLab/vRhyme/raw/master/vRhyme/models/vRhyme_machine_model_ET.sav.gz" && \
    gunzip vRhyme_machine_model_ET.sav.gz && \
    mv vRhyme_machine_model_ET.sav /opt/conda/lib/python3*/site-packages/vRhyme/models/

RUN micromamba clean --all --yes
