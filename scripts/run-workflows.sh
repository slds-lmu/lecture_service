#! /bin/bash

if [[ -z $1 ]]
then
  lectures=(lecture_i2ml lecture_sl lecture_advml lecture_optimization)
  echo "No argument provided, getting default set of lectures: ${lectures[@]}"
else
  lectures=($1)
  echo "Selected lecture: $lectures"
fi

echo ""

for lecture in ${lectures[@]}
do
  echo "Starting workflow for ${lecture}..."
  echo "gh workflow run render-lecture-slide-status --repo slds-lmu/${lecture}"
done