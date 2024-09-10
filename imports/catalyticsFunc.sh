#!/bin/bash
# Source the resolve_import.sh script
source "$(dirname "${BASH_SOURCE[0]}")/resolve_import.sh"

json_funcs=$(resolve_import "json_funcs.sh") && source "$json_funcs"
helpers=$(resolve_import "helpers.sh") && source "$helpers"

# Main Category Analytics code
### Does file filtering, then counts, builds json 
### Finally writes file through call to update_category_json_catalytics_props
catalytics() {
    #Parse Params
    local dir="$1"
    local childrenCharCount=$2
    local childrenFileCount=$3
    local extensions="$4"
    local includeOrExclude="$5"
    

    #Additional Vars
    local docCountSelf=0
    local characterCountSelf=0
    local hasSubdirectories=false
    local docs=()
    local subDirs=()

    local filesToAnalyze=()
    # Filtering functions -- pass 'filesToAnalyze' by reference
    filterDirFilesByExtension "$dir" "$extensions" "$includeOrExclude" filesToAnalyze #Populates filesToAnalyze 
    ignoreCategoryJson filesToAnalyze # Modifies filesToAnalyze in place

    # Count documents and calculate character counts
    for file in "${filesToAnalyze[@]}"; do
        echo "outer{$file}"
        if [ -f "$file" ]; then
        docCountSelf=$(($docCountSelf + 1))
        characterCountSelf=$(($characterCountSelf + $(calculate_character_count "$file")))
        docs+=("{\"filename\": \"$(basename "$file")\", \"characterCount\": $(calculate_character_count "$file")}")
        fi
    done
    echo "count complete"
    local docCount=($docCountSelf+$childrenFileCount)
    local characterCount=($characterCountSelf+$childrenCharCount)

    # Check for subdirectories
    for subDir in "$dir"/*/; do
        if [ -d "$subDir" ]; then
        hasSubdirectories=true
        subDirs+=("{\"subDirName\": \"$(basename "$subDir")\"}")
        fi
    done

    echo "start json"
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
    echo $catalytics_object
    echo "call writer"
    update_category_json_catalytics_props "$dir" "$catalytics_object" "$exclude" 
  
}