#!/bin/bash
# Function to calculate the character count of a file
calculate_character_count() {
  local file="$1"
  wc -m < "$file" | tr -d ' '
}

# Function to recursively calculate total character count in a directory
# calculate_total_character_count() {
#   local dir="$1"
#   local total_count=0

#   for file in "$dir"/*; do
#     if [ -f "$file" ]; then
#       total_count=$((total_count + $(calculate_character_count "$file")))
#     elif [ -d "$file" ]; then
#       total_count=$((total_count + $(calculate_total_character_count "$file")))
#     fi
#   done

#   echo "$total_count"
# }


filterFilesByExtension() {
    local -n files="$1"          # The input array passed by reference
    local extensions="$2"
    local include_or_exclude="$3"
    local -n resultArray=$4      # Result array passed by reference

    local filteredFiles=()

    # Check if the include_or_exclude parameter is valid
    if [[ "$include_or_exclude" != "include" && "$include_or_exclude" != "exclude" ]]; then
        printf "=================================================================================\n" >&2
        printf "ERROR: The third parameter must be either 'include' or 'exclude'\. You passed: %s \n" "$include_or_exclude" >&2
        printf "=================================================================================\n" >&2
        return 1
    fi

    # No filtering
    if [[ -z "$extensions" ]]; then
        resultArray=("${files[@]}")
        return 0
    fi 

    # Validate extensions input
    for ext in ${extensions//,/ }; do
        clean=$(echo "$ext" | tr -d '[:space:]')
        firstChar=${clean:0:1}
        if [ "$firstChar" == "." ]; then 
            printf "=================================================================================\n"
            echo "ERROR: You passed in an extension with a leading dot. This function expects extensions without the leading dot (e.g., 'sql' not '.sql')."
            printf "=================================================================================\n"
            return 1
        fi
    done

    # Loop through each file in the input list of files
    for file in "${files[@]}"; do
        local match_found=false

        # Check file extensions for "include" or "exclude"
        for ext in ${extensions//,/ }; do
            if [[ "$file" == *.$ext ]]; then
                match_found=true
                break
            fi
        done

        # Handle inclusion or exclusion logic
        if [[ "$include_or_exclude" == "include" && "$match_found" == true ]]; then
            filteredFiles+=("$file")
        elif [[ "$include_or_exclude" == "exclude" && "$match_found" == false ]]; then
            filteredFiles+=("$file")
        fi
    done

    # Assign the filtered files array to the result array (pass by reference)
    resultArray=("${filteredFiles[@]}")
}

filterDirFilesByExtension() {
    local dir="$1"
    local extensions="$2"
    local include_or_exclude="$3"
    local -n resultArr=$4  # Return array passed by reference
    
    # Gather all files in the directory (with full paths)
    local fileNames=()
    for file in "$dir"/*; do
        if [ -f "$file" ]; then  # Ensure it's a regular file
            fileNames+=("$file")
        fi
    done

    # Call filterFilesByExtension to handle the actual filtering
    filterFilesByExtension fileNames "$extensions" "$include_or_exclude" resultArr
    
}


ignoreCategoryJson() {
  local -n urisIn=$1  # Pass by reference, modify in place

  # Iterate backwards so popping items won't affect indices of earlier items
  for ((i=${#urisIn[@]}-1; i>=0; i--)); do
    if [[ $(basename "${urisIn[i]}") == "_category_.json" ]]; then
      unset 'urisIn[i]'  # Remove item in place
    fi
  done
}

