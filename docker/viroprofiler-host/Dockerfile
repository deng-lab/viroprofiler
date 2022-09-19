FROM mambaorg/micromamba:0.25.1

LABEL author="Jinlong Ru"

USER root

# Activate conda env during docker build
ARG MAMBA_DOCKERFILE_ACTIVATE=1
ENV PATH=/opt/conda/bin:$PATH

COPY docker/viroprofiler-host/env_host.yml /tmp

RUN --mount=type=cache,target=/opt/conda/pkgs micromamba install -n base -f /tmp/env_host.yml -y

RUN micromamba clean --all --yes

COPY docker/viroprofiler-host/activate/update_bioperl.sh /opt/conda/etc/conda/activate.d/
COPY docker/viroprofiler-host/deactivate/update_bioperl.sh /opt/conda/etc/conda/deactivate.d/

RUN chmod +x /opt/conda/etc/conda/activate.d/update_bioperl.sh && \
    chmod +x /opt/conda/etc/conda/deactivate.d/update_bioperl.sh
