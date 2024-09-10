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

# Add _category_.json - catalytics writes to json b/c it calls update_category_json_catalytics_props
write_category_json_basic_template "$(pwd)"


## === Act === ## 


## === Assert === ## 



## === Cleanup === ## 
# script execution should not change pwd 
cd $START_DIR

#Remove temp directories and files


