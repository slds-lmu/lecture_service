#! /bin/bash
# WIP wrapper for gh to trigger workflows in lecture repos. Should only be used interactively, and currently
# only supports one hardcoded workflow.

# Read list of included lectures from global file, ignore commented lines
lectures=$(grep -v "^[#/]" include_lectures)
# make it a bash array
lectures=(${lectures})

if [[ -z $1 ]]
then
  echo "No argument provided, getting default set of lectures: ${lectures[@]}"
else
  lectures=($1)
  echo "Selected lecture: $lectures"
fi

run_workflow () {
  gh workflow run "${1}" --repo "slds-lmu/${2}"
}

echo ""

for lecture in ${lectures[@]}
do
  for workflow in update-latex-math.yaml render-lecture-slide-status.yaml
  do
    read -p "Do you sure you want to start workflow ${workflow} for ${lecture}? (y/n) " -n 1 -r
    echo    # (optional) move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        #gh workflow run render-lecture-slide-status --repo slds-lmu/${lecture}
        #gh workflow run update-latex-math --repo slds-lmu/${lecture}
        run_workflow "${workflow}" "${lecture}"
        #echo "gh workflow run ${workflow} --repo slds-lmu/${lecture}"
    fi
  done
done
