#!/bin/bash

source ../imports/helpers.sh

# Test function
test_ignoreCategoryJson() {
  # Arrange: set up test input and expected output
  local inputPaths=(
    "/path/to/file1.md"
    "/path/to/_category_.json"
    "/another/path/file2.md"
    "/yet/another/_category_.json"
    "/yet/another/file3.md"
  )

  local expectedOutput=(
    "/path/to/file1.md"
    "/another/path/file2.md"
    "/yet/another/file3.md"
  )

  # Act: Call the function, modifying inputPaths in place
  ignoreCategoryJson inputPaths

  # Assert: Compare inputPaths with expectedOutput
  if [[ "${inputPaths[@]}" == "${expectedOutput[@]}" ]]; then
    echo "Test Passed - test_ignoreCategoryJson"
  else
    echo "!!!!!!Test Failed - test_ignoreCategoryJson!!!!!!!!"
    echo "Expected: ${expectedOutput[@]}"
    echo "Got: ${inputPaths[@]}"
  fi

   if [[ "$1" == "verbose" ]]; then
    echo "Input Paths (After Filtering): ${inputPaths[@]}"
    echo "Expected Output: ${expectedOutput[@]}"
  fi
}

# Run the test (-v parsed to support runner params)
 if [[ "$1" == "-v" ]]; then
    test_ignoreCategoryJson "verbose"
else
    test_ignoreCategoryJson
 fi
