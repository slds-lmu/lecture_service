#! /bin/bash

# Installing diff-pdf-visually
# https://pypi.org/project/diff-pdf-visually/
# Requires python3
if ! [ -x "$(command -v diff-pdf-visually)" ]
then
  echo "Attempting to install diff-pdf-visually..."
  # Also needs pip(3)
  if ! [ -x "$(command -v pip3)" ]; then
    # Also needs pip(3)
    echo "Need to install python3-pip first..."
    sudo apt-get install -y python3-pip
  fi

  echo "Installing dependencies..."
  sudo apt-get install -y imagemagick poppler-utils
  echo "Installing diff-pdf-visually via pip3..."
  pip3 install --user diff-pdf-visually
  echo "Done!"
fi

# Installing diff-pdf
# https://vslavik.github.io/diff-pdf/
# diff-pdf needs to be built from source
if ! [ -x "$(command -v diff-pdf)" ]
then
  echo "Attempting to install diff-pdf..."
  echo "Installing dependencies..."
  sudo apt-get install -y libpoppler-glib-dev poppler-utils libwxgtk3.0-gtk3-dev

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
  sudo make install
  echo "Done!"
  cd -
fi
