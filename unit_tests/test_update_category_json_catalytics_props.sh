#!/bin/bash

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

##### ========================================================= #####
## === Test 1: Just the basics - Writing Properties === ##
##### ========================================================= #####
echo ""
echo "Running Test 1: Writing Properties"

## === Arrange === ## 

# Make temp directory for files supporting the test 
dirForThisTest="_temp_/jq_testing/test_1"

# Cleanup Potential Existing
if [ -d $dirForThisTest ]; then
  rm -rf $dirForThisTest
fi

mkdir -p "$dirForThisTest"
cd "$dirForThisTest"

# Add _category_.json - catalytics writes to json b/c it calls update_category_json_catalytics_props
write_category_json_basic_template "$(pwd)"
addIfNotExist_catalytics_props_to_json "$(pwd)"

#Create cagtalytics object
declare -i docCount=2
declare -i characterCount=4
hasSubdirectories=false

# Define the docs array with the necessary structure
docs=(
    '{"filename":"six_char.md","characterCount":6}'
    '{"filename":"test.txt","characterCount":5}'
)

# Define the subDirs array (empty in this case)
subDirs=()

runDatetime=$(date +"%Y-%m-%d %H:%M:%S")

#always cast to string if the variable could potentially have spaces  
catalytics_object=$(cat <<EOF
        {
            "runDatetime": "$runDatetime",
            "docCount": $docCount,
            "characterCount": $characterCount,
            "hasSubdirectories": $hasSubdirectories,
            "docs": [
            $(IFS=,; echo "${docs[*]}")
            ],
            "subDirs": [
            $(IFS=,; echo "${subDirs[*]}")
            ]
        }
EOF
)

## === Act === ## 
update_category_json_catalytics_props "$(pwd)" "$catalytics_object" "false"


## === Assert === ## 
fileUri="$(pwd)/_category_.json"

## Check 1: A single property value 
echo "Running Check 1: Check a specific property (this example uses docCount)"
expectedDCVar=$docCount
actualDCVar=$(jq '.catalytics.docCount' $fileUri)
if [[ "$actualDCVar" == "null" ]]; then
    echo "Check Failed: .catalytics.docCount is not present in _category_.json"
else 
    if [[ $actualDCVar -eq $expectedDCVar ]]; then
        echo "Check Passed"
    else 
        echo "Check Failed: - Actual: ${actualDCVar} Expected: ${expectedDCVar}"
    fi
fi

## Check 2: Datetime property written
echo "Running Check 2: Was the runDatetime property written?"
actualdt=$(jq '.catalytics.runDatetime' $fileUri)
if [[ "$actualdt" == "null" ]]; then
    echo "Check Failed: datetime prop not written"
    echo $actualdt
else 
    echo "Check Passed"
fi


cd ../../../
##### ========================================================= #####
## === Test 2: Writing when there are Spaces === ##
##### ========================================================= #####
echo ""
echo "Running Test 2: Writing when there are Spaces (Actually creates dir & file with spaces in name)"
dirForThisTest="_temp_/jq_testing/test_2"
# Cleanup Potential Existing
if [ -d $dirForThisTest ]; then
  rm -rf $dirForThisTest
fi

## === Arrange === ## 
mkdir -p "$dirForThisTest"
cd "$dirForThisTest"
mkdir "d i r"
cd "d i r"
echo  "something" > "file.txt"
cd ../
echo  "sdfsdf" > "s p a c e"
fileUri="$(pwd)/_category_.json"

# Add _category_.json - catalytics writes to json b/c it calls update_category_json_catalytics_props
write_category_json_basic_template "$(pwd)"
addIfNotExist_catalytics_props_to_json "$(pwd)"

# Define the docs array with the necessary structure
docs=()

# Define the subDirs array
subDirs=()

# Add Subdirs
for thing in "./$dir"/*; do
    if [[ -d "$thing" ]]; then #only add directories
        hasSubdirectories=true
        subDirs+=("{\"subDirName\": \"$(basename "$thing")\"}")
    fi
    if [[ -f "$thing" ]]; then #only add files
        docs+=("{\"filename\": \"$(basename "$thing")\"}")
    fi
done

catalytics_object=$(cat <<EOF
        {
            "docsSelf": [
            $(IFS=,; echo "${docs[*]}")
            ],
            "subDirs": [
            $(IFS=,; echo "${subDirs[*]}")
            ]
        }
EOF
)

## === Act === ## 
update_category_json_catalytics_props "$(pwd)" "$catalytics_object" "true"

## === Assert === ## 
## Check 1: Dir with space
echo "Running Check 1: Directory with space written properly?"
expectedDirName="d i r"
dirNameWritten=$(jq -r '.catalytics.subDirs[0].subDirName' $fileUri)
if [[ "$dirNameWritten" == "null" ]]; then
    echo "Check Failed: .catalytics.subDirs[0] is not present in _category_.json"
else 
    if [[ "$dirNameWritten" == "$expectedDirName" ]]; then
        echo "Check Passed"
    else 
        echo "Check Failed: - Actual: ${dirNameWritten} Expected: ${expectedDirName}"
    fi
fi

## Check 2: Filename with space
echo "Running Check 2: Filename with space written properly?"
expected="s p a c e"
actual=$(jq -r '.catalytics.docsSelf[1].filename' $fileUri) #idx 1 b/c category.json not exlcuded in test
if [[ "$expected" == "null" ]]; then
    echo "Check Failed: .catalytics.docsSelf[1].filename is not present in _category_.json"
else 
    if [[ $expected == $actual ]]; then
        echo "Check Passed"
    else 
        echo "Check Failed: - Actual: ${actual} Expected: ${expected}"
    fi
fi

#Added this because some syntax errors can cause the script to silently stop executing
echo "End of Tests: $(basename "$0")" 


