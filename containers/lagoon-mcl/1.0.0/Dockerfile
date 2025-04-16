FROM condaforge/miniforge3

RUN ln -s /usr/share/zoneinfo/Europe/Paris /etc/localtime

RUN apt-get update && \
    apt-get install -y --no-install-recommends pandoc pandoc-citeproc

RUN mamba install -y -c conda-forge python=3.12.6=hc5c86c4_2_cpython && \
    mamba install -y -c conda-forge pandas=2.2.3=py312hf9745cd_1 && \
    mamba install -y -c conda-forge python-igraph=0.11.8=py312h3262465_0 && \
    mamba install -y -c conda-forge biopython=1.85=py312h66e93f0_1 && \
    mamba install -y -c conda-forge numpy=2.2.2=py312h72c5963_0 && \
    mamba install -y -c conda-forge jinja2=3.1.5=pyhd8ed1ab_0 && \
    mamba install -y -c conda-forge seaborn=0.13.2=hd8ed1ab_3
    
RUN mamba clean --all -y

