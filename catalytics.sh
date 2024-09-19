# === Start of ./imports/catalyticsFunc.sh ===
catalytics() {
    # Parse Params
    local dir="$1"
    local -i childrenCharCount=$2
    local -i childrenFileCount=$3
    local extensions="$4"
    local includeOrExclude="$5"
    
    # Additional Vars
    local -i docCountSelf=0
    local -i characterCountSelf=0
    local hasSubdirectories=false
    local docs=()
    local subDirs=()

    local filesToAnalyze=()
    # Filtering functions -- pass 'filesToAnalyze' by reference
    filterDirFilesByExtension "$dir" "$extensions" "$includeOrExclude" filesToAnalyze #Populates filesToAnalyze 
    ignoreCategoryJson filesToAnalyze # Modifies filesToAnalyze in place

    # Count documents and calculate character counts
    for file in "${filesToAnalyze[@]}"; do
        if [ -f "$file" ]; then
        docCountSelf=$(($docCountSelf + 1))
        characterCountSelf=$(($characterCountSelf + $(calculate_character_count "$file")))
        docs+=("{\"filename\": \"$(basename "$file")\", \"characterCount\": $(calculate_character_count "$file")}")
        fi
    done

    local -i docCount=$(($docCountSelf + $childrenFileCount)) 
    local -i characterCount=$(($characterCountSelf + $childrenCharCount))

    # Check for subdirectories
    for subDir in "$dir"/*/; do
        if [ -d "$subDir" ]; then
        hasSubdirectories=true
        subDirs+=("{\"subDirName\": \"$(basename "$subDir")\"}")
        fi
    done
    
    runDateTime=$(date +"%Y-%m-%d %H:%M:%S")

    #### Generate the JSON template with all the values 
    catalytics_object=$(cat <<EOF
 {
            "overall": {
            "runDatetime": $runDateTime,
            "docCount": $docCount,
            "characterCount": $characterCount,
            "hasSubdirectories": $hasSubdirectories
            },
            "docs": [
            $(IFS=,; echo "${docs[*]}")
            ],
            "subDirs": [
            $(IFS=,; echo "${subDirs[*]}")
            ]
        }
EOF
)

update_category_json_catalytics_props "$dir" "$catalytics_object" "false"

  
}

# $(IFS=,; echo "${subDirs[*]}")
# === End of ./imports/catalyticsFunc.sh ===
# === Start of ./imports/helpers.sh ===
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
        printf "ERROR: The third parameter must be either 'include' or 'exclude'\. You passed: %s" "$include_or_exclude" >&2
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
            echo "ERROR: You passed in an extension with a leading dot. This function expects extensions without the leading dot (e.g., 'sql' not '.sql')."
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

# === End of ./imports/helpers.sh ===
# === Start of ./imports/json_funcs.sh ===
check_and_create_category_json() {
  local directory="$1"
  local category_file="${directory}/_category_.json"

  if [ ! -f "$category_file" ]; then
    echo "_category_.json not found in $directory. Creating..."
    write_category_json_basic_template "$directory"
  fi
}

write_category_json_basic_template() {
  local directory="$1"
  local folder_name=$(basename "$directory")

  local template_content=$(cat <<EOF
{
  "label": "$folder_name",
  "link": {
    "type": "generated-index",
    "description": "PK_ToDo Write Description"
  }
}
EOF
)

  echo "$template_content" > "${directory}/_category_.json"
  echo "Template written to ${directory}/_category_.json"
}

addIfNotExist_catalytics_props_to_json() {
  local directory="$1"
  local category_file="${directory}/_category_.json"

  if [ ! -f "$category_file" ]; then
    echo "Error: ${category_file} does not exist."
    return 1
  fi

  local catalytics_exists=$(jq 'has("catalytics")' "$category_file")
  local exclude_exists=$(jq 'has("exclude")' "$category_file")

  # Create a temporary file to hold the updated JSON
  local tmp_file=$(mktemp)

  # If 'catalytics' is missing, add it
  if [ "$catalytics_exists" != "true" ]; then
    echo "Adding missing property 'catalytics' to ${category_file}."
    jq '. + {"catalytics": {}}' "$category_file" > "$tmp_file" && mv "$tmp_file" "$category_file"
  fi

  # If 'exclude' is missing, add it with a default value
  if [ "$exclude_exists" != "true" ]; then
    echo "Adding missing property 'exclude' to ${category_file}."
    jq '. + {"exclude": false}' "$category_file" > "$tmp_file" && mv "$tmp_file" "$category_file"
  fi
}

update_category_json_catalytics_props() {
  local directory="$1"
  local catalytics_object="$2"
  local exclude_value="$3"
  local category_file="${directory}/_category_.json"

  if [ ! -f "$category_file" ]; then
    echo "Error: ${category_file} does not exist."
    return 1
  fi
  
  # Create a temporary file to hold the updated JSON
  local tmp_file=$(mktemp)

  # Update the catalytics and exclude properties
  jq --argjson catalytics "$catalytics_object" --argjson exclude "$exclude_value" \
  '.catalytics = $catalytics | .exclude = $exclude' \
  "$category_file" > "$tmp_file" && mv "$tmp_file" "$category_file"
}


testFunc(){
 echo "Test func from json_funcs"
}
# === End of ./imports/json_funcs.sh ===
# === Start of ./imports/process_directory.sh ===
process_directory() {
  local dir="$1"
  local extensions="$2"
  local includeOrExclude="$3"
  local childrenCharCount=$4
  local childrenFileCount=$5
  local -n retChildrenFileCount=
  
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
# === End of ./imports/process_directory.sh ===
# === Start of ./imports/resolve_import.sh ===
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
# === End of ./imports/resolve_import.sh ===
# === Start of main.sh ===
# Set your character count threshold here
THRESHOLD=1000

# Default list of top-level subdirectories to analyze (can be overridden by --subdirs)
TARGET_SUBDIRS=()

# Default base directory is the current working directory
BASE_DIR="."

# Function to display usage information
usage() {
  echo "Usage: $0 [--dir <directory>] [--subdirs <subdir1,subdir2,...>] [-list_ext] [-h|--help]"
  echo
  echo "Options:"
  echo "  --dir <directory>     Specify the top-level directory relative to the current working directory."
  echo "                        Required for some operations (e.g., -list_ext)."
  echo "  --subdirs <subdirs>   Specify a comma-separated list of subdirectories to analyze."
  echo "                        If not provided, all subdirectories will be analyzed."
  echo "  -list_ext             List unique file extensions in the specified directory."
  echo "                        Useful for including/excluding files by extension in future operations."
  echo "  -h, --help            Show this help message and exit."
  echo
  echo "Notes:"
  echo "  - The order of the parameters generally does not matter."
  echo "  - Ensure that --dir is specified before using -list_ext. (To ensure main does not execute)"
  echo

  # Exit after showing usage
  read -p "Press any key to continue (Ctrl + C to exit)..."
}

askShowDocs(){
   read -p "Show docs? [y/n] " response
      if [[ "$response" == "y" || "$response" == "Y" ]]; then
        usage
      fi
}

ARG_PARSE_SUCCESS=true
EXECUTE_MAIN=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dir)
      if [[ -n "$2" && ! "$2" =~ ^-- ]]; then
        BASE_DIR="$2"
        EXECUTE_MAIN=true
        shift 2
      else
        ARG_PARSE_SUCCESS=false
        echo "Error: --dir requires a non-empty argument."
        askShowDocs
        break     
      fi
      ;;
    --subdirs)
      if [[ -n "$2" && ! "$2" =~ ^-- ]]; then
        IFS=',' read -r -a TARGET_SUBDIRS <<< "$2"
        shift 2
      else
        ARG_PARSE_SUCCESS=false
        echo "Error: --subdirs requires a comma-separated list of subdirectories."
        askShowDocs
        break
      fi
      ;;
    --ext_excl)
      if [[ -n "$2" && ! "$2" =~ ^-- ]]; then
        IFS=',' read -r -a _ <<< "$2"
        shift 2
      else
        ARG_PARSE_SUCCESS=false
        echo "Error: --."
        askShowDocs
        break
      fi
      ;;
    --ext_incl)
      if [[ -n "$2" && ! "$2" =~ ^-- ]]; then
        IFS=',' read -r -a _ <<< "$2"
        shift 2
      else
        ARG_PARSE_SUCCESS=false
        echo "Error: --."
        askShowDocs
        break
      fi
      ;;
    -h|--help)
      usage
      shift 1
      ;;
    -list_ext)
      LIST_EXT=true
      shift 1
      ;;
    *)
      echo "Error: Unknown option: $1"
      usage
      shift 1
      ;;
  esac

  # Exit the loop once all arguments are parsed
  if [[ $# -eq 0 ]]; then
    break
  fi
done


if $ARG_PARSE_SUCCESS; then
  echo "Args Processed"
  ## List Ext
  if $LIST_EXT; then
    if [[ "$BASE_DIR" == "" ]]; then
      echo "Error: --dir is required to use -list_ext."
      return 1
    fi

    if [[ ! -d "$BASE_DIR" ]]; then
      echo "Error: '$BASE_DIR' is not a valid directory."
      return 1
    fi

    echo "File extensions in directory: $BASE_DIR"
    find "$BASE_DIR" -type f | awk -F. '/\./ {print $NF}' | sort -u
    read -p "Press Ctrl + C to Exit"
    return 0
  fi

  ## Main Catalytics Script
  if $EXECUTE_MAIN; then
    echo "Starting update"
    # Convert BASE_DIR to absolute path for consistency
    if ! BASE_DIR_ABS=$(cd "$BASE_DIR" 2>/dev/null && pwd); then
      echo "Error: Directory '$BASE_DIR' does not exist."
      return 1  
    fi

    # If no --subdirs flag was provided, analyze all subdirectories in the base directory
    if [ ${#TARGET_SUBDIRS[@]} -eq 0 ]; then
      for dir in "$BASE_DIR_ABS"/*/; do
        TARGET_SUBDIRS+=("$(basename "$dir")")
      done
    fi

    # Analyze the specified (or all) subdirectories within the base directory
    for target_subdir in "${TARGET_SUBDIRS[@]}"; do
      full_path="$BASE_DIR_ABS/$target_subdir"
      if [ -d "$full_path" ]; then
        # Recursively analyze each target subdirectory
        find "$full_path" -type d | while read -r dir; do
          echo "Outer loop: $dir"
          # process_directory "$dir"
        done
      else
        echo "Subdirectory '$target_subdir' not found in '$BASE_DIR_ABS'."
      fi
    done
    echo "Update completed."
  fi
fi
# === End of main.sh ===
