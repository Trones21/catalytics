#!/bin/bash

# Function to resolve path of the target file
resolve_import() {
  local target="$1"
  local script_dir="$( cd "$( dirname "${BASH_SOURCE[1]}" )" && pwd )"

  # Try to find the target file in various locations
  if [[ -f "$script_dir/$target" ]]; then
    echo "$script_dir/$target"
  elif [[ -f "$script_dir/../imports/$target" ]]; then
    echo "$script_dir/../imports/$target"
  else
    echo "Error: $target not found!" >&2
    read -p "Ctrl + C to exit"
  fi
}
