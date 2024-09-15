#!/bin/bash

source ../imports/catalyticsFunc.sh
source ../imports/json_funcs.sh

## Normalize dirs because we are using things like mkdir and cd with relative paths

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the current working directory
START_DIR="$(pwd)"

# If the current directory is not the script's directory, change to the script's directory
if [ "$START_DIR" != "$SCRIPT_DIR" ]; then
  cd "$SCRIPT_DIR"
  echo "Changed directory to: $SCRIPT_DIR"
fi

## === Arrange === ## 

# Make temp directory for files supporting the test 
dirForThisTest="_temp_/catalyticsfunc/"
mkdir -p "$dirForThisTest"
cd "$dirForThisTest"

# Add Files 
#Remember that echo adds an extra character at the end
echo "test" > test.txt
echo "6char" > six_char.md

# Add _category_.json - catalytics writes to json b/c it calls update_category_json_catalytics_props
write_category_json_basic_template "$(pwd)"
addIfNotExist_catalytics_props_to_json "$(pwd)"

## === Act === ## 
cd $SCRIPT_DIR
catalytics "$dirForThisTest" 0 0 "" "exclude" 

## === Assert === ## 
cd "$dirForThisTest"
jsonUri="$(pwd)/_category_.json"
## echo $jsonUri

## Check json file
declare -i expected_docCountSelf=2
declare -i expected_charCountSelf=11
# docCount and charCount should contain the same values because there are no subdirectories
expected_hasSubdirectories=false


## Possible improvement - loop over array of properties (or the big alternative... compare the entire json)
cd ../../
## echo "$(pwd)"

actualDCSelf=$(jq '.catalytics.overall.docCountSelf' $jsonUri)
if [[ "$actualDCSelf" == "null" ]]; then
    echo "Case Failed .catalytics.overall.docCountSelf is not present in _category_.json"
else 
  if [[ $actualDCSelf -eq $expected_docCountSelf ]]; then
      echo "Case Passed"
  else 
      echo "Case Failed - Actual: ${actualDCSelf} Expected: ${expected_docCountSelf}"
  fi
fi

## Check that we have the updated arrays 

## print category.json for verbose output
if [[ "$1" == "-v" ]]; then
  printf "%s\n" "$(jq '.' $jsonUri)"
fi

## === Cleanup === ## 
# script execution should not change pwd 
cd $START_DIR

# Remove temp directories and files


