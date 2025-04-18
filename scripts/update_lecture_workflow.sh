#! /bin/bash
# WIP helper to update workflows in dependant lecture repos



if [[ "$(basename ${PWD})" != "lecture_service" ]]; then
    echo "This is intended to be run from the lecture_service repo, not ${PWD}!"
    exit 1
else
    echo "This script aussumes lecture_* repos are: "
    echo "- In a clean state"
    echo "- On the default branch"
    echo "- Ready to commit and push"

    read -p "Are you sure you want update, commit and push workflows? (y/n) " -n 1 -r
    echo    # (optional) move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        echo "OK!"
    else
        echo "Aborting"
        exit 0
    fi
fi

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
  for workflow in update-latex-math.yaml render-lecture-slide-status.yaml pr-slide-check.yaml
  do
    read -p "Do you sure you want to copy workflow ${workflow} for ${lecture}? (y/n) " -n 1 -r
    echo    # (optional) move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        echo "Copying service/.github/workflows/${workflow} to ${lecture}/.github/workflows/${workflow}"
        # -r for recursive
        cp "service/.github/workflows/${workflow}" "${lecture}/.github/workflows/${workflow}"
    fi
  done
done

        # rsync -r "service/.github/" "${lecture}/.github/"
        # git -C "${lecture}" add .github
        # git -C "${lecture}" commit -m "Update workflows"
        # git -C "${lecture}" push
