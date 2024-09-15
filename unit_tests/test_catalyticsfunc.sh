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

## Check 1: Was the catalytics object populated?
echo "Running Check 1: Was the catalytics object populated?"
actual_catalytics=$(jq '.catalytics' $jsonUri)

if [[ "$actual_catalytics" == "null" ]]; then
    echo "Check Failed .catalytics is not present in _category_.json"
else 
    echo "Check Passed"
fi

## Check 2: Path written correctly 
echo "Running Check 2: Was the path property written correctly?"
actual=$(jq -r '.catalytics.myPath' $jsonUri)
expected="_temp_/catalyticsfunc/"

if [[ $actual == $expected ]]; then
    echo "Check Passed"
else 
    echo "Check Failed: - Actual: ${actual} Expected: ${expected}"
fi

## Check 3: Did the docs array populate correctly?
echo "Running Check 3: Did the docs array populate correctly?"
echo "Check 3 Failed -- To be implemented"

## Check 4: Did the subDirs array populate correctly?
echo "Running Check 4: Did the subDirs array populate correctly?"
echo "Check 4 Failed -- To be implemented"

## print category.json for verbose output
if [[ "$1" == "-v" ]]; then
  printf "%s\n" "$(jq '.' $jsonUri)"
fi

## === Cleanup === ## 
# script execution should not change pwd 
cd $START_DIR

# Remove temp directories and files


#Added this because some syntax errors can cause the script to silently stop executing
echo "End of Tests: $(basename "$0")" 