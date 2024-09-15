#!/bin/bash
# Source the resolve_import.sh script
source "$(dirname "${BASH_SOURCE[0]}")/resolve_import.sh"

json_funcs=$(resolve_import "json_funcs.sh") && source "$json_funcs"
catalyticsFunc=$(resolve_import "catalyticsFunc.sh") && source "$catalyticsFunc"

process_directory() {
  local dir="$1"
  local extensions="$2"
  local includeOrExclude="$3"
  local childrenCharCount=$4
  local childrenFileCount=$5
  local -n retChildrenFileCount=$6
  
  # Step 3: Recursively process subdirectories (Post-Order Processing)
  for subdir in "$dir"/*/; do
    if [ -d "$subdir" ]; then
      process_directory "$subdir" "$extensions" "$includeOrExclude"
    fi
  done
  
  echo "============ Processing dir: $dir ==========="
  # Step 1: Check for _category_.json and create it if not found
  check_and_create_category_json "$dir"
  addIfNotExist_catalytics_props_to_json "$dir"

  #Do Catalytics 
  catalytics "$dir" "$childrenCharCount" "$childrenFileCount" "$includeOrExclude" "$extensions" 

}
