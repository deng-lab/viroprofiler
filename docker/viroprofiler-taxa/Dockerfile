FROM mambaorg/micromamba:0.25.1

USER root

COPY ./docker/viroprofiler-taxa/env_*.yml /tmp

# Install packages into `base` env, because nextflow can't use other envs.
RUN --mount=type=cache,target=/opt/conda/pkgs micromamba install -n base -f /tmp/env_taxa.yml -y && \
    micromamba clean --all --yes

# Activate conda env during docker build
ARG MAMBA_DOCKERFILE_ACTIVATE=1


RUN cd /opt/conda/lib/python3.8/site-packages/vcontact2/data && \
    /opt/conda/bin/wget https://bitbucket.org/MAVERICLab/vcontact2/raw/6089ed83fd03a844de3140c442863c7b29881d43/vcontact2/data/ViralRefSeq-prokaryotes-v211.Merged-reference.csv && \
    /opt/conda/bin/wget https://bitbucket.org/MAVERICLab/vcontact2/raw/6089ed83fd03a844de3140c442863c7b29881d43/vcontact2/data/ViralRefSeq-prokaryotes-v211.faa.gz && \
    /opt/conda/bin/wget https://bitbucket.org/MAVERICLab/vcontact2/raw/6089ed83fd03a844de3140c442863c7b29881d43/vcontact2/data/ViralRefSeq-prokaryotes-v211.protein2contig.csv

# Set PATH manually, because nextflow doesn't activate base env by default.
# ENV PATH=/opt/MMseqs2/build/bin:/opt/conda/bin:$PATH
ENV PATH=/opt/mmseqs/bin:/opt/MMseqs2/build/bin:/opt/conda/bin:$PATH

# RUN cd /opt && \
#     git clone --depth=1 https://github.com/soedinglab/MMseqs2.git && \
#     cd /opt/MMseqs2 && \
#     git checkout 3b9cf88 && \
#     mkdir build && \
#     cd build && \
#     cmake -DHAVE_SANITIZER=1 -DCMAKE_BUILD_TYPE=ASan -DCMAKE_INSTALL_PREFIX=. .. && \
#     make -j 1 && \
#     make install

RUN micromamba clean --all --yes


# COPY ./docker/viroprofiler-taxa/mmseqs /opt/conda/bin
# RUN chmod +x /opt/conda/bin/mmseqs

RUN cd /opt && \
    wget https://mmseqs.com/latest/mmseqs-linux-avx2.tar.gz; tar xvfz mmseqs-linux-avx2.tar.gz; rm mmseqs-linux-avx2.tar.gz