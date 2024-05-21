FROM continuumio/anaconda3

# updating and installing dependencies
RUN apt-get update && apt install -y procps g++

# seqkit download and creation of the /data directory which will contain the data for the analyzes
RUN conda install -c conda-forge -c bioconda mcl==22.282=pl5321h031d066_1

RUN conda install -c bioconda diamond=2.1.8=h43eeafb_0

RUN conda install -c conda-forge -c bioconda foldseek=9.427df8a=pl5321hb365157_0

RUN conda install python=3.11.8=h955ad1f_0 && \
    conda install pip=23.3.1=py311h06a4308_0 && \
    conda install pandas=2.0.3=py311ha02d727_0

RUN conda install r-base=4.3.1=h1ae530e_0 && \
    conda install r-dplyr=1.1.3=r43h884c59f_0 && \
    conda install r-ggplot2=3.4.4=r43h6115d3f_0 && \
    conda install r-magrittr=2.0.3=r43h76d94ec_0 && \
    conda install r-scales=1.2.1=r43h6115d3f_0 && \
    conda install r-tidyr=1.3.0=r43h884c59f_0

RUN mkdir data

# set /data as working directory
WORKDIR /data
