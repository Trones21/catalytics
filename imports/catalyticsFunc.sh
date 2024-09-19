#!/bin/bash
# Source the resolve_import.sh script
source "$(dirname "${BASH_SOURCE[0]}")/resolve_import.sh"

json_funcs=$(resolve_import "json_funcs.sh") && source "$json_funcs"
helpers=$(resolve_import "helpers.sh") && source "$helpers"

# Main Category Analytics code
### Does file filtering, then counts, builds json 
### Finally writes file through call to update_category_json_catalytics_props
catalytics() {
    # Parse Params
    local dir="$1" # let's say this takes the full path?
    local -i childrenCharCount=$2
    local -i childrenFileCount=$3
    local extensions="$4"
    local includeOrExclude="$5"
    
    # Additional Vars
    local -i fileCountSelf=0
    local -i characterCountSelf=0
    local hasSubdirectories=false
    local files=()
    local subDirs=()

    local filesToAnalyze=()
    # Filtering functions -- pass 'filesToAnalyze' by reference
    filterDirFilesByExtension "$dir" "$extensions" "$includeOrExclude" filesToAnalyze #Populates filesToAnalyze 
    ignoreCategoryJson filesToAnalyze # Modifies filesToAnalyze in place

    # Count documents and calculate character counts
    for file in "${filesToAnalyze[@]}"; do
        if [[ -f "$file" ]]; then
            printf "===============file: %s \n" "$file" >&2
            fileCountSelf=$((fileCountSelf + 1))
            characterCountSelf=$((characterCountSelf + $(calculate_character_count "$file")))
            files+=("{\"filename\": \"$(basename "$file")\", \"characterCount\": $(calculate_character_count "$file")}")
        fi
    done

    # Check for subdirectories
    for subDir in "$dir"/*/; do
        if [[ -d "$subDir" ]]; then
        hasSubdirectories=true
        subDirs+=("{\"subDirName\": \"$(basename "$subDir")\"}")
        fi
    done
    
    runDatetime="$(date +"%Y-%m-%d %H:%M:%S")"

    #### Generate the JSON template with all the values 
    # always cast to string if the variable could potentially have spaces 
    if [[ "$hasSubdirectories" == true ]]; then
        local subDirStats
        subDirStats=$(cat <<EOF
        "fileCountSubDirs": $childrenFileCount,
        "characterCountSubDirs": $childrenCharCount,
EOF
    )
    fi
    catalytics_object=$(cat <<EOF
 {
            "myPath": "$dir",
            "runDatetime": "$runDatetime",
            "fileCountSelf": $fileCountSelf,
            "characterCountSelf": $characterCountSelf,
            $subDirStats
            "hasSubdirectories": $hasSubdirectories,
            "filesSelf": [
            $(IFS=,; echo "${files[*]}")
            ],
            "subDirsImmediate": [
            $(IFS=,; echo "${subDirs[*]}")
            ]
        }
EOF
)

update_category_json_catalytics_props "$dir" "$catalytics_object" "false"

# Returning total (for accumlulation )
local -i fileCount=$((fileCountSelf + childrenFileCount)) 
local -i characterCount=$((characterCountSelf + childrenCharCount))

echo -n "${fileCount}:${characterCount}"
}

