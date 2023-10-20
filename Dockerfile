FROM rocker/verse

WORKDIR /home/rstudio

RUN install2.r --error --skipmissing --deps TRUE --skipinstalled \
  pak \
  rmarkdown kableExtra tinytex \
  dplyr ggplot2 \
  fs cli here processx checkmate future future.apply tictoc git2r

ADD ./scripts /home/rstudio/scripts/
ADD ./R /home/rstudio/R
ADD ./man /home/rstudio/man
ADD ./NAMESPACE /home/rstudio/NAMESPACE
ADD ./DESCRIPTION /home/rstudio/
ADD ./Makefile /home/rstudio/
ADD ./lecheck /usr/local/bin/lecheck

RUN make install-tex
RUN make install-tools-ubuntu
RUN make install-service

#RUN 
