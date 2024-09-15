#!/bin/bash

source ../imports/helpers.sh

## Normalize dirs because we are using things like mkdir and cd with relative paths

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the current working directory
CURRENT_DIR="$(pwd)"

# If the current directory is not the script's directory, change to the script's directory
if [ "$CURRENT_DIR" != "$SCRIPT_DIR" ]; then
  cd "$SCRIPT_DIR"
  echo "Changed directory to: $SCRIPT_DIR"
fi

## === Arrange === ## 

#Make temp directory for files supporting the test 
dirForThisTest="_temp_/filterFilesByExtension"
mkdir -p "$dirForThisTest"
cd "$dirForThisTest"

#Create Files 
files=("file1.txt" "file2.md" "file3.sql" "file4.cpp")
for file in "${files[@]}"
do
    touch "$file"
done

dirToAnalyze="$(pwd)" 
extensions="md","cpp"
cd ../../
filesOut=()

##  === Act === ## 
filterDirFilesByExtension "$dirToAnalyze" "$extensions" "include" filesOut

# Cleanup - Delete the temp directory 
rm -rf "$SCRIPT_DIR/_temp_"

## === Assert === ##
expected="$dirToAnalyze/file2.md $dirToAnalyze/file4.cpp"
actual="${filesOut[@]}"

# Compare the strings with double quotes to handle spaces correctly
if [ "$expected" == "$actual" ]; then
    echo "Test Passed - filterDirFilesByExtension"
else
    echo "Test Failed - Expected not equal to Actual"
    echo "Expected: $expected"
    echo "Actual: $actual"
fi



#Added this because some syntax errors can cause the script to silently stop executing
echo "End of Tests: $(basename "$0")" 