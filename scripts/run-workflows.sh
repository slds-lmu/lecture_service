#! /bin/bash
# WIP wrapper for gh to trigger workflows in lecture repos. Should only be used interactively, and currently
# only supports one hardcoded workflow.

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

echo ""

for lecture in ${lectures[@]}
do
  read -p "Are you sure you want to start workflow render-lecture-slide-status for ${lecture}? (y/n) " -n 1 -r
  echo    # (optional) move to a new line
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
      gh workflow run render-lecture-slide-status --repo slds-lmu/${lecture}
      #echo "gh workflow run render-lecture-slide-status --repo slds-lmu/${lecture}"
  fi
done
