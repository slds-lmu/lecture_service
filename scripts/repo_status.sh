#! /bin/bash
# WIP helper check local repo status

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

echo ""

for lecture in ${lectures[@]}
do
  BRANCH=$(git -C "${lecture}"  rev-parse --abbrev-ref HEAD)

  echo "${lecture} / ${BRANCH}:"
  git -C "${lecture}" status --short
done

