#!/bin/bash
# Source the resolve_import.sh script
source "$(dirname "${BASH_SOURCE[0]}")/resolve_import.sh"

json_funcs=$(resolve_import "json_funcs.sh") && source "$json_funcs"
catalyticsFunc=$(resolve_import "catalyticsFunc.sh") && source "$catalyticsFunc"


## Pass extensions space separated without the leading dots
process_directory() {
  local dir="$1"
  local extensions="$2"
  local includeOrExclude="$3"
  local childrenCharCount=0
  local childrenFileCount=0

  #printf "pd called with %s \n" "$dir" >&2
  # Step 3: Recursively process subdirectories
  for subdir in "$dir"/*; do
    #printf "subdir loop iteration: %s \n" "$subdir" >&2
    if [ -d "$subdir" ]; then
      #printf "inside if: %s \n" "$subdir" >&2 
      local countsStr
      countsStr=$(process_directory "$subdir" "$extensions" "$includeOrExclude")
      printf "process_directory returned: %s \n" "$countsStr" >&2
      # Assuming countsStr is in the format "fileCount:charCount"
      local subdirFileCount
      subdirFileCount=$(echo "$countsStr" | cut -d':' -f1)
      local subdirCharCount
      subdirCharCount=$(echo "$countsStr" | cut -d':' -f2)
      # printf "fc: %s" "$subdirFileCount"
       # Accumulate the results from the subdirectory
      childrenFileCount=$((childrenFileCount + subdirFileCount))
      childrenCharCount=$((childrenCharCount + subdirCharCount))
    fi
  done
  
  #echo "============ Processing dir: $dir === ${childrenFileCount}==${childrenCharCount}======"
  # Step 1: Check for _category_.json and create it if not found
  check_and_create_category_json "$dir"
  addIfNotExist_catalytics_props_to_json "$dir"

  # Do Catalytics 
  local ret
  ret=$(catalytics "$dir" "$childrenCharCount" "$childrenFileCount" "$extensions" "$includeOrExclude") 
  printf "%s" "$ret" 
}
