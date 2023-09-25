#! /bin/bash

# Goal: Identify R files in slides/*/rsrc and run them
# Ideally we would only rerun them if output files are not present but nontrivial to verify

ROOT=$(PWD)

find "$(pwd)/slides" -name "rsrc" -type d | while read -r folder; do
    echo "entering $folder"
    cd $folder # scripts assume PWD is the respective rscr folder, have relative paths for ggsave etc.

    echo "\nRunning R scripts...\n"
    find . -iname "*.R"  -exec Rscript {} \;
done

# Go back to where we started
cd $ROOT
