#!/bin/bash

set -euo pipefail

mkdir -p apimartifacts

# Keep a copy of the file seperator
saved_IFS=$IFS
${IFS+':'} unset saved_IFS

# Do an envsubst from apim_templates to apimartifacts
all_files=$(find apim_templates -type f -print)
IFS=$'\n'

for fileName in ${all_files[@]}; do
    [ -e "$fileName" ] || continue
    echo "Processing ${fileName}"
    # Remove the leading "apim_templates" from the filename
    newFileName="${fileName#apim_templates/}"
    # Create the directory structure in apimartifacts
    mkdir -p "./apim_artifacts/$(dirname ${newFileName})"
    envsubst < "${fileName}" > "./apim_artifacts/${newFileName}";
done

# Restore the file seperator
IFS=$saved_IFS
${saved_IFS+':'} unset IFS
