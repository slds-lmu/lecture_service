#! /bin/bash

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
echo "----------------------------------------------------"

for lecture in ${lectures[@]}
do
  if [[ ! -d ${lecture} ]]
  then
    echo "Cloning ${lecture}..."
    # --depth 1 only gets the current state as fetching the whole history is not necessary and slow
    # --single-branch is supposed to only clone the default branch, to avoid wastign time on branches we don't need
    git clone --depth 1 --single-branch https://github.com/slds-lmu/${lecture} &
  else
    echo "$lecture already exists, updating current branch..."
    # We only pull the current branch to speed this up
    # -C executes git in the specified directory, so we don't need to cd and keep track of where we are
    BRANCH=$(git -C ${lecture} rev-parse --abbrev-ref HEAD)
    git -C ${lecture} pull origin ${BRANCH}
  fi

  echo ""
done

echo "Waiting for git clone to finish..."
wait # Block so we don't accidentally move on expecting downloads to be complete while they are still in progress
echo "Done!"

exit 0
