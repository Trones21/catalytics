#!/bin/bash
check_and_create_category_json() {
  local directory="$1"
  local category_file="${directory}/_category_.json"

  if [ ! -f "$category_file" ]; then
    printf "_category_.json not found in %s. Creating... \n" "$directory" >&2
    write_category_json_basic_template "$directory"
    return 0
  fi
  return 0
}

write_category_json_basic_template() {
  local directory="$1"
  local folder_name
  folder_name=$(basename "$directory")

  local template_content
  template_content=$(cat <<EOF
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
  printf "Template written to %s/_category_.json \n" "$directory" >&2
  return 0
}

addIfNotExist_catalytics_props_to_json() {
  local directory="$1"
  local category_file="${directory}/_category_.json"

  if [ ! -f "$category_file" ]; then
    echo "Error: ${category_file} does not exist."
    return 1
  fi

  local catalytics_exists
  catalytics_exists=$(jq 'has("catalytics")' "$category_file")
  local exclude_exists
  exclude_exists=$(jq 'has("exclude")' "$category_file")

  # Create a temporary file to hold the updated JSON
  local tmp_file
  tmp_file=$(mktemp)

  # If 'catalytics' is missing, add it
  if [ "$catalytics_exists" != "true" ]; then
    #echo "Adding missing property 'catalytics' to ${category_file}."
    jq '. + {"catalytics": {}}' "$category_file" > "$tmp_file" && mv "$tmp_file" "$category_file"
  fi

  # If 'exclude' is missing, add it with a default value
  if [ "$exclude_exists" != "true" ]; then
    #echo "Adding missing property 'exclude' to ${category_file}."
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
  local tmp_file
  tmp_file=$(mktemp)

  # Update the catalytics and exclude properties
  jq --argjson catalytics "$catalytics_object" --argjson exclude "$exclude_value" \
  '.catalytics = $catalytics | .exclude = $exclude' \
  "$category_file" > "$tmp_file" && mv "$tmp_file" "$category_file"

  return 0
}


testFunc(){
 echo "Test func from json_funcs"
}