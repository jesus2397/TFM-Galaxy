FROM bgruening/galaxy-stable:20.09


RUN apt-get update -qq
RUN apt-get install -y --no-install-recommends software-properties-common dirmngr
RUN apt-get install wget
RUN apt-get install -y make cmake gfortran libcurl4-openssl-dev zlib1g-dev libxml2-dev libfontconfig1-dev
RUN apt-get install -y libjpeg-dev libpng-dev libxml2-dev liblapack-dev libblas-dev libssl-dev libudunits2-dev libgeos-dev libfreetype6-dev libtiff5-dev
RUN apt-get install -y libharfbuzz-dev libfribidi-dev libgdal-dev libcairo2-dev
RUN wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc

RUN add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/"
RUN apt install -y --no-install-recommends r-base




RUN R -e "install.packages( c('ggplot2'), dependencies=TRUE, repos='http://cran.rstudio.com' )"
RUN R -e "install.packages( c('dplyr'), dependencies=TRUE, repos='http://cran.rstudio.com' )"
RUN R -e "install.packages( c('tidyr'), dependencies=TRUE, repos='http://cran.rstudio.com' )"
RUN R -e "install.packages( c('getopt'), dependencies=TRUE, repos='http://cran.rstudio.com' )"
RUN R -e "install.packages( c('tibble'), dependencies=TRUE, repos='http://cran.rstudio.com' )"
RUN R -e "install.packages( c('tidyverse'), dependencies=TRUE, repos='http://cran.rstudio.com' )"
RUN R -e "install.packages( c('gtools'), dependencies=TRUE, repos='http://cran.rstudio.com' )"
RUN R -e "install.packages( c('nloptr'), dependencies=TRUE, repos='http://cran.rstudio.com' )"
RUN R -e "install.packages( c('Cairo'), dependencies=TRUE, repos='http://cran.rstudio.com' )"
RUN R -e "install.packages( c('DESeq2'), dependencies=TRUE, repos='http://cran.rstudio.com' )"
RUN R -e "install.packages( c('tibble'), dependencies=TRUE, repos='http://cran.rstudio.com' )"
RUN R -e "install.packages( c('ape'), dependencies=TRUE, repos='http://cran.rstudio.com' )"
RUN R -e "install.packages( c('phyloseq'), dependencies=TRUE, repos='http://cran.rstudio.com' )"
RUN R -e "install.packages( c('vegan'), dependencies=TRUE, repos='http://cran.rstudio.com' )"
