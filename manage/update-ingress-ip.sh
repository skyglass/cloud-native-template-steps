#! /bin/bash -e

set -o pipefail

tf_files_array=()

while IFS= read -r file; do
  tf_files_array+=("$file")
done < <(find terraform-eks -type d -name '.*' -prune -o -type f -name '*.tf' -print)

if [ ${#tf_files_array[@]} -eq 0 ]; then
  echo "Error: Failed to find .tf files in terraform-eks directory"
  exit 1
fi

sd '[1-9][0-9]{0,3}\.[0-9]{1,4}\.[0-9]{1,4}\.[0-9]{1,4}/32' "$(curl -s http://checkip.amazonaws.com)/32" "${tf_files_array[@]}"

git diff HEAD
