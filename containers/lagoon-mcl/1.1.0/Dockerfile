FROM condaforge/miniforge3

RUN ln -s /usr/share/zoneinfo/Europe/Paris /etc/localtime

RUN apt-get update && \
    apt-get install -y --no-install-recommends pandoc pandoc-citeproc

COPY quarto-1.5.57-linux-amd64.deb /

RUN apt-get install -y ./quarto-1.5.57-linux-amd64.deb && \
    rm -f quarto-1.5.57-linux-amd64.deb && \
    apt-get clean

RUN mamba install -y -c conda-forge python=3.12.6=hc5c86c4_2_cpython && \
    mamba install -y -c conda-forge pandas=2.2.3=py312hf9745cd_1 && \ 
    mamba install -y -c conda-forge r-base=4.4.1=h64c9cd0_16 && \
    mamba install -y -c conda-forge r-dplyr=1.1.4=r44h0d4f4ea_1 && \
    mamba install -y -c conda-forge r-ggplot2=3.5.1=r44hc72bb7e_1 && \
    mamba install -y -c conda-forge r-argparse=2.2.3=r44hc72bb7e_1 && \
    mamba install -y -c conda-forge r-knitr=1.49=r44hc72bb7e_0 && \
    mamba install -y -c conda-forge r-rmarkdown=2.29=r44hc72bb7e_0 && \    
    mamba install -y -c conda-forge r-readr=2.1.5=r44h0d4f4ea_1
    
RUN mamba clean --all -y

