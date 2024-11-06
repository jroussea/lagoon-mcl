FROM condaforge/miniforge3

RUN ln -s /usr/share/zoneinfo/Europe/Paris /etc/localtime

RUN apt-get update && \
    apt-get install -y --no-install-recommends pandoc pandoc-citeproc wget

RUN	wget https://github.com/quarto-dev/quarto-cli/releases/download/v1.5.57/quarto-1.5.57-linux-amd64.deb && \
	chmod +x quarto-1.5.57-linux-amd64.deb && \
	apt-get install -y ./quarto-1.5.57-linux-amd64.deb && \
    rm -f quarto-1.5.57-linux-amd64.deb

RUN mamba install -c conda-forge -c bioconda python=3.12.6 && \
    mamba install -c conda-forge -c bioconda pandas=2.2.3 && \ 
    mamba install -c conda-forge -c bioconda r-base=4.3.1 && \
    mamba install -c conda-forge -c bioconda r-dplyr=1.1.3 && \
    mamba install -c conda-forge -c bioconda r-ggplot2=3.4.4 && \
    mamba install -c conda-forge -c bioconda r-magrittr=2.0.3 && \
    mamba install -c conda-forge -c bioconda r-scales=1.2.1 && \
    mamba install -c conda-forge -c bioconda r-tidyr=1.3.0 && \
    mamba install -c conda-forge -c bioconda r-knitr && \
    mamba install -c conda-forge -c bioconda r-rmarkdown && \
    mamba install -c conda-forge -c bioconda r-readr

