FROM rocker/verse

WORKDIR /home/rstudio

ENV INSIDE_SERVICE_DOCKER=1

RUN apt-get update && apt-get install -y imagemagick \
  poppler-utils \
  libpoppler-glib-dev \
  libwxgtk3.0-gtk3-dev \
  python3-pip

RUN install2.r --error --skipmissing --deps TRUE --skipinstalled \
  pak \
  rmarkdown kableExtra tinytex \
  dplyr ggplot2 \
  fs cli here processx checkmate future future.apply tictoc git2r

RUN Rscript -e "tinytex::install_tinytex(force = TRUE)"
RUN tlmgr install latexmk

ADD ./scripts /home/rstudio/scripts/
ADD ./R /home/rstudio/R
ADD ./man /home/rstudio/man
ADD ./NAMESPACE /home/rstudio/NAMESPACE
ADD ./DESCRIPTION /home/rstudio/
ADD ./Makefile /home/rstudio/
ADD ./inst/lecheck /bin/lecheck

RUN make install-tools-ubuntu
RUN make install-service
RUN make install-tex
RUN rm -r R man NAMESPACE DESCRIPTION

RUN mkdir work
WORKDIR work
