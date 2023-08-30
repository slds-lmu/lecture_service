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

echo ""

for lecture in ${lectures[@]}
do
  echo "Starting workflow for ${lecture}..."
  echo "gh workflow run render-lecture-slide-status --repo slds-lmu/${lecture}"
done
