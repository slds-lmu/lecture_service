#! /bin/bash
# Download contents of lecture repos without cloning
# Intended for use in CI, where there is no need for a git history or $ git pull
# Downloading a tarball from the API is assumed to be faster than running `git clone`, even considering --depth 1 etc.

if ! [ -x "$(command -v jq)" ]
then
  echo "jq needs to be installed for this!"
  exit 1
fi

# Read list of included lectures from global file, ignore commented lines
lectures=$(grep -v "^[#/]" LECTURES_INCLUDE)
# make it a bash array
lectures=(${lectures})

if [[ -z $1 ]]
then
  echo "No argument provided, getting default set of lectures: ${lectures[@]}"
else
  lectures=($1)
  echo "Selected lecture: $lectures"
fi

echo "Lectures will be cloned in current directory: ${PWD}"
echo "--------------------------------------------"

for lecture in ${lectures[@]}
do
  if [[ ! -d ${lecture} ]]
  then
    # Using  GitHub API to get the name of the default branch (some use main, some still use master), and then
    # jq to parse the JSON output, with -r to get the raw value without quotes (main rather than "main")
    BRANCH=$(curl -sL https://api.github.com/repos/slds-lmu/$lecture | jq -r '.default_branch')

    echo "Starting download for ${lecture} branch ${BRANCH}..."
    mkdir ${lecture} # Output directory needs to exist
    # fetching tarball of default branch and untaring in the appropriate directory, forking to the background with &
    curl -sL https://api.github.com/repos/slds-lmu/${lecture}/tarball/${BRANCH} | tar -xz --directory=${lecture} --strip-components=1 &
  else
    echo "${lecture} already exists, doing nothing."
    echo "Delete ${lecture} and re-run this script to fetch a new version."
    echo "For incremental updates, maybe use clone_lectures.sh instead."
  fi
done

echo "Waiting for downloads to finish..."
wait # Block so we don't accidentally move on expecting downloads to be complete while they are still in progress
echo "Done!"

exit 0
