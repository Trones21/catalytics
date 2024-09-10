# Main Category Analytics code
catalytics() {
    #Parse Params
    local dir="$1"
    local childrenCharCount=$2
    local childrenFileCount=$3
    local includeOrExclude="$4"
    local $extensions="$5"

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
    for file in "{$filesToAnalyze[@]}"; do
        if [ -f "$file" ]; then
        docCountSelf=$((docCount + 1))
        characterCountSelf=$((characterCount + $(calculate_character_count "$file")))
        docs+=("{\"filename\": \"$(basename "$file")\", \"characterCount\": $(calculate_character_count "$file")}")
        fi
    done

    local docCount=$docCountSelf + $childrenFileCount
    local characterCount=$characterCountSelf + $childrenCharCount

    # Check for subdirectories
    for subDir in "$dir"/*/; do
        if [ -d "$subDir" ]; then
        hasSubdirectories=true
        subDirs+=("{\"subDirName\": \"$(basename "$subDir")\"}")
        fi
    done

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