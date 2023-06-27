# Galaxy - My own flavour
#
# VERSION       0.1

FROM bgruening/galaxy-stable:20.09


RUN mkdir /galaxy-central/tools/IonTorrent

COPY galaxy/tools/IonTorrent/ /galaxy-central/tools/IonTorrent/
COPY galaxy/lib/galaxy/config/sample/tool_conf.xml.sample /galaxy-central/lib/galaxy/config/sample/tool_conf.xml.sample
COPY galaxy/static/* /galaxy-central/static/
COPY galaxy/static/* /etc/galaxy/web/


RUN chown -R galaxy:galaxy /galaxy-central/tools/IonTorrent/
RUN chown galaxy:galaxy /galaxy-central/lib/galaxy/config/sample/tool_conf.xml.sample

#Instalar dependencias
RUN apt-get update
RUN apt-get install -y apt-utils libcurl4-openssl-dev && \
    apt-get install -y libxml2-dev liblapack-dev libblas-dev && \
    apt-get install -y wget libpng-dev libjpeg-dev gfortran libfontconfig1-dev && \
    apt-get install -y libssl-dev libudunits2-dev libgeos-dev libharfbuzz-dev libfribidi-dev libgdal-dev && \
    apt-get install -y libcairo2-dev libxt-dev libmagick++-dev pandoc && \
    apt-get install -y --no-install-recommends software-properties-common dirmngr
#Instalar R
RUN wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc
RUN add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/"
RUN apt install -y --no-install-recommends r-base

# Instalar paquetes de R
RUN R -e "install.packages( c('ggplot2','dplyr','tidyr', 'getopt','tibble','vegan','ape','tidyverse','gtools'), dependencies=TRUE, repos='http://cran.rstudio.com/') "
RUN R -e "install.packages('BiocManager', dependencies=TRUE, repos='http://cran.rstudio.com/' )"
RUN R -e "BiocManager::install(c('limma','DESeq2','phyloseq'))"
RUN R -e "install.packages(c('kableExtra'), dependencies=TRUE, repos='http://cran.rstudio.com/')"

# Configura ficheros galaxy
RUN echo 'sanitize_all_html: false' >>/galaxy-central/lib/galaxy/config/sample/galaxy.yml.sample
RUN cd /home/galaxy &&  wget https://github.com/marbl/Krona/releases/download/v2.8.1/KronaTools-2.8.1.tar && tar -xvf KronaTools-2.8.1.tar
RUN cd /home/galaxy/KronaTools-2.8.1/ && ./install.pl
RUN chown -R galaxy:galaxy /home/galaxy/KronaTools-2.8.1
COPY startup /usr/bin/startup
RUN chown galaxy:galaxy /usr/bin/startup
# CMD ["/bin/bash"]
