#!/bin/bash
# Source the resolve_import.sh script
source ../imports/helpers.sh

## === Arrange === ## 

# Make temp directory for files supporting the test 
dirForThisTest="_temp_/calculate_chacter_counts/"
mkdir -p "$dirForThisTest"
cd "$dirForThisTest"

# Add Files 
echo "test" > countme.txt
#Remember that echo adds a newline character 
# so even though it looks like 4 chars it is actually 5
## === Act === ##
actual=$(calculate_character_count "countme.txt")


expected=5
if [[ $actual -ne $expected ]]; then
    echo "Test Failed Actual: ${actual} Expected:${expected}" 
else
    echo "Test Passed"
fi

#Cleanup
cd ../../
rm -rf './_temp_/'