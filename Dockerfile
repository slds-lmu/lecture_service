FROM rocker/verse:4.3

LABEL org.label-schema.license="GPL-2.0" \
      org.label-schema.vcs-url="https://github.com/slds-lmu/lecture_service" \
      org.label-schema.vendor="SLDS LMU" \
      maintainer="Lukas Burk <Lukas.Burk@stat.uni-muenchen.de>"

WORKDIR /home/rstudio

ENV INSIDE_SERVICE_DOCKER=1

RUN apt-get update && apt-get install -y imagemagick \
  poppler-utils \
  libpoppler-glib-dev \
  libwxgtk3.0-gtk3-dev \
  python3-pip \
  jq

RUN install2.r --error --deps TRUE --skipinstalled \
  pak docopt \
  rmarkdown kableExtra \
  dplyr ggplot2 \
  fs cli here processx checkmate future future.apply tictoc git2r \
  tinytex

RUN rm -rf /usr/local/texlive

ADD ./scripts /home/rstudio/scripts/
ADD ./R /home/rstudio/R
ADD ./man /home/rstudio/man
ADD ./NAMESPACE /home/rstudio/NAMESPACE
ADD ./DESCRIPTION /home/rstudio/
ADD ./Makefile /home/rstudio/
ADD ./inst/lecheck /bin/lecheck
ADD ./include_lectures include_lectures

RUN make install-tools-ubuntu
RUN make install-service
RUN rm -r R man NAMESPACE DESCRIPTION

# Installing tinytex and stuff as non-root to make PATHs work
# This is the result of a lot of trial and error and can likely be streamlined
# but I just don't want to deal with this anymore at this point.
USER rstudio
RUN Rscript -e "tinytex::install_tinytex(force = TRUE)"
RUN make install-tex

# Need to be root at the end otherwise container can't start rstudio server
USER root
RUN mv /home/rstudio/.TinyTeX/ /opt/tinytex
ENV PATH="/opt/tinytex/bin/x86_64-linux:$PATH"
RUN echo "export PATH=$PATH:/opt/tinytex/bin/x86_64-linux" >> /etc/profile.d/tinytex.sh

# Avoid running in home dir so that mapping local dirs into the container
# doesn't result in all sorts of dotfile detritus
RUN mkdir work
WORKDIR work
