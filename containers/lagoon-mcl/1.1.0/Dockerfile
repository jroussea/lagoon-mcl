FROM condaforge/miniforge3

RUN ln -s /usr/share/zoneinfo/Europe/Paris /etc/localtime

RUN apt-get update && \
    apt-get install -y --no-install-recommends pandoc pandoc-citeproc

COPY quarto-1.5.57-linux-amd64.deb /

RUN apt-get install -y ./quarto-1.5.57-linux-amd64.deb && \
    rm -f quarto-1.5.57-linux-amd64.deb

RUN mamba install -c conda-forge python=3.12.6=hc5c86c4_2_cpython && \
    mamba install -c conda-forge pandas=2.2.3=py312hf9745cd_1 && \ 
    mamba install -c conda-forge r-base=4.3.1=h93585b2_6 && \
    mamba install -c conda-forge r-dplyr=1.1.3=r43ha503ecb_0 && \
    mamba install -c conda-forge r-ggplot2=3.4.4=r43hc72bb7e_0 && \
    mamba install -c conda-forge r-scales=1.2.1=r43hc72bb7e_2 && \
    mamba install -c conda-forge r-tidyr=1.3.0=r43ha503ecb_1 && \
    mamba install -c conda-forge r-knitr=1.49=r43hc72bb7e_0 && \
    mamba install -c conda-forge r-rmarkdown=2.29=r43hc72bb7e_0 && \
    mamba install -c conda-forge r-readr=2.1.5=r43h0d4f4ea_1

