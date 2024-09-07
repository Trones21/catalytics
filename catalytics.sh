#!/bin/bash
source ./imports/json_funcs.sh
source ./imports/helpers.sh

# Set your character count threshold here
THRESHOLD=1000

# Default list of top-level subdirectories to analyze (can be overridden by --subdirs)
TARGET_SUBDIRS=()

# Default base directory is the current working directory
BASE_DIR="."

process_directory() {
  local dir="$1"
    # Step 3: Recursively process subdirectories
  for subdir in "$dir"/*/; do
    if [ -d "$subdir" ]; then
      process_directory "$subdir"
    fi
  done
  
  echo "============ Processing dir: $dir ==========="
  # Step 1: Check for _category_.json and create it if not found
  check_and_create_category_json "$dir"
  addIfNotExist_catalytics_props_to_json "$dir"

  #Do Catalytics 
  catalytics "$dir"


}

# Main Category Analytics code
catalytics() {
  local dir="$1"
  
  # Initialize variables
  local docCount=0
  local characterCount=0
  local docCountSelf=0
  local characterCountSelf=0
  local hasSubdirectories=false
  local docs=()
  local subDirs=()
  
  local extensions=""
  local filesToAnalyze=()
  # Call the functions and pass 'filesToAnalyze' by reference
  filterDirFilesByExtension "$dir" "$extensions" filesToAnalyze
  ignoreCategoryJson "$filesToAnalyze" filesToAnalyze

    # Count documents and calculate character counts
    for file in "{$filesToAnalyze[@]}"; do
      if [ -f "$file" ]; then
        docCount=$((docCount + 1))
        characterCount=$((characterCount + $(calculate_character_count "$file")))
        docs+=("{\"filename\": \"$(basename "$file")\", \"characterCount\": $(calculate_character_count "$file")}")
      fi
    done

    docCountSelf=$docCount
    characterCountSelf=$characterCount

    # Check for subdirectories
    for subDir in "$dir"/*/; do
      if [ -d "$subDir" ]; then
        hasSubdirectories=true
        subDirs+=("{\"subDirName\": \"$(basename "$subDir")\"}")
      fi
    done

    # Calculate the total character count for the entire directory including children
    totalCharacterCount=$(calculate_total_character_count "$dir")
    echo "$dir Files: $docCount Chars: $totalCharacterCount"
    # Determine if the directory should be excluded based on the threshold
    exclude=false
    if [ "$totalCharacterCount" -lt "$THRESHOLD" ]; then
      exclude=true
    fi

    # Generate the JSON template with all the values
    catalytics_object=$(cat <<EOF
        {
          "overall": {
            "docCount": $docCount,
            "characterCount": $characterCount,
            "docCountSelf": $docCountSelf,
            "characterCountSelf": $characterCountSelf,
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

  update_category_json_catalytics_props "$dir" "$catalytics_object" "$exclude" 
  
}



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