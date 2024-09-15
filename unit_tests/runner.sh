#!/bin/bash

# To run a single test just run the .sh file, this was simply created for convenience when running multiple tests 

## By convention  -- Try to add verbose output for tests to visually compare the actual with expected
# Define ANSI color codes


# Function to colorize keywords
colorize_output() {
  RED='\033[31m'
  GREEN='\033[32m'
  YELLOW='\033[33m'
  BLUE='\033[34m'
  PURPLE='\033[35m'
  RESET='\033[0m'

    # Check if a color argument is provided
  if [ -n "$1" ]; then
    # Determine the color based on the argument
    case $1 in
      red) color=$RED ;;
      green) color=$GREEN ;;
      yellow) color=$YELLOW ;;
      blue) color=$BLUE ;; 
      purple) color=$PURPLE ;; 
      *) echo "Invalid color option. Use red, green, or yellow."; return 1 ;;
    esac

    # Colorize the entire input from stdin
    while IFS= read -r line; do
      echo -e "${color}${line}${RESET}"
    done
  else

  # Default behavior: colorize specific keywords "Failed" and "Passed"
    sed -e "s/Failed/$(printf $RED)&$(printf $RESET)/g" \
        -e "s/Passed/$(printf $GREEN)&$(printf $RESET)/g" \
        -e "s/End of Tests/$(printf $BLUE)&$(printf $RESET)/g" 
  fi
}

testsToRun=()

if [[ "$1" == "-a" ]]; then
  #Match all files starting with test_
  echo "======== Matching all tests in unit_tests directory ========" | colorize_output blue 
  for test in test_*; do
    testsToRun+=($test)
  done 
else
  #Run Specific Tests
  echo "======== Running only the tests specified in runner.sh ========" | colorize_output blue
  testsToRun+=(./test_ignoreCategoryJson.sh)
  testsToRun+=(./test_catalyticsfunc.sh)
  testsToRun+=(./test_update_category_json_catalytics_props.sh)
fi

for test in ${testsToRun[@]}; do
    echo $test | colorize_output purple
    bash $test | colorize_output
    echo "" 
done
