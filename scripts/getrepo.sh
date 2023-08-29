#! /bin/bash
# Downloads contents of GitHub repository slds-lmu/REPO to a folder named REPO.
# Output folder can optionally be specified with the second argument.
# No git checkout, just curl

# Set default values for $REPO and $OUT if not already set
REPO=$1
OUT=${2:-$REPO}

# Make sure $REPO is not empty
if [ -z "$REPO" ]; then
  echo "Usage: $0 REPO [OUTPUT PATH]"
  echo "Example: $0 latex-math"
  echo "Example: $0 latex-math temp-latex-math"
  exit 1
fi

# Retrieve the contents of the repository and save them in $OUT
curl -sL https://api.github.com/repos/slds-lmu/$REPO/tarball/master | tar -xz --directory=$OUT --strip-components=1

echo "Repository $REPO contents saved in $OUT"
