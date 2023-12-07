#! /bin/bash

# Installing diff-pdf-visually
# https://pypi.org/project/diff-pdf-visually/
# Requires python3
if ! [ -x "$(command -v diff-pdf-visually)" ]
then
  echo "Attempting to install diff-pdf-visually..."
  # Also needs pip(3)
  if [ -z ${INSIDE_SERVICE_DOCKER} ]
  # Don't run this inside the docker container
  then
    if ! [ -x "$(command -v pip3)" ]; then
      # Also needs pip(3)
      echo "Need to install python3-pip first..."
      sudo apt-get install -y python3-pip
    fi

    echo "Installing dependencies..."
    sudo apt-get install -y imagemagick poppler-utils
  fi
  echo "Installing diff-pdf-visually via pip3..."
  if [ $(id -u) = 0 ]
  then
    echo "Root detected, installing globally"
    pip3 install diff-pdf-visually
  else
    echo "User not root, installing for user $(id -un)"
    pip3 install --user diff-pdf-visually

    # As of 2023-12-07, apparently pip3 installs to
    # $HOME/.local/lib/python3.10/site-packages/diff_pdf_visually, which is not in path
    # and the binary name is different for some reason. Trying this band-aid.
    if [ $(whoami) = "runner" ]
    then
     ln -s $HOME/.local/lib/python3.10/site-packages/diff_pdf_visually $HOME/bin/diff-pdf-visually
    fi
  fi
  echo "-------------"
  echo "--- Done! ---"
  echo "Installed diff-pdf-visually:"
  pip3 show diff-pdf-visually
  echo "Checking if it's in path: $(command -v diff-pdf-visually)"
else
  echo "Found diff-pdf-visually at $(command -v diff-pdf-visually)"
fi

# Installing diff-pdf
# https://vslavik.github.io/diff-pdf/
# diff-pdf needs to be built from source
if ! [ -x "$(command -v diff-pdf)" ]
then
  echo "Attempting to install diff-pdf..."
  # Don't run this inside the docker container
  if [ -z ${INSIDE_SERVICE_DOCKER} ]
  then
    echo "Installing dependencies..."
    sudo apt-get install -y libpoppler-glib-dev poppler-utils libwxgtk3.0-gtk3-dev
  fi

  TEMPDIR=$(mktemp -d)
  cd $TEMPDIR
  echo "Cloning vslavik/diff-pdf to ${TEMPDIR}..."
  git clone --depth 1 --single-branch https://github.com/vslavik/diff-pdf.git
  cd diff-pdf
  echo "Compiling..."
  ./bootstrap
  ./configure
  make
  echo "Installing..."
  if [ $(id -u) = 0 ]
  then
    make install
  else
    echo "Not root - trying to use sudo to install..."
    sudo make install
   fi
  echo "-------------"
  echo "--- Done! ---"
  echo "Installed diff-pdf to $(command -v diff-pdf)"
  cd -
else
  echo "Found diff-pdf at $(command -v diff-pdf)"
fi
