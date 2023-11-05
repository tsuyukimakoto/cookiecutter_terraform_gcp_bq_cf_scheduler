#!/bin/bash

extension=".tf"

declare -a target_dirs=("../environment/dev" "../environment/prod")

for file in *"$extension"; do
  echo "$file"
done

for file in ls *$extension; do
  if [[ -f "$file" ]]; then
    for dir in "${target_dirs[@]}"; do
      [[ -d "$dir" ]] || continue
      link_path="$dir/$file"

      if [[ ! -L "$link_path" ]]; then
        ln -s "$(pwd)/$file" "$link_path"
        echo "Created link for $file in $dir"
      else
        echo "Link for $file in $dir already exists"
      fi
    done
  fi
done
