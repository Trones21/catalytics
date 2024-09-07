#!/bin/bash

source ../imports/helpers.sh

echo 

## === Tests === ##

run_tests() {

    ## === Test 1: Include only .md and .cpp files === ##
    echo "Running Test 1: Include only .md and .cpp files"
    filesToAnalyze=("/path/to/file1.txt" "/path/to/file2.md" "/path/to/file3.sql" "/path/to/file4.cpp")
    expected_files=("/path/to/file2.md" "/path/to/file4.cpp")
    filesOut=()
    extensions="md,cpp"
    
    # Act
    filterFilesByExtension filesToAnalyze "$extensions" "include" filesOut
    
    # Assert
    actual_files="${filesOut[@]}"
    expected="${expected_files[@]}"
    
    if [ "$expected" == "$actual_files" ]; then
        echo "Test 1 Passed"
    else
        echo "Test 1 Failed"
        echo "Expected: $expected"
        echo "Actual: $actual_files"
    fi

    ## === Test 2: Exclude .md and .cpp files === ##
    echo "Running Test 2: Exclude .md and .cpp files"
    expected_files=("/path/to/file1.txt" "/path/to/file3.sql")
    filesOut=()
    extensions="md,cpp"
    
    # Act
    filterFilesByExtension filesToAnalyze "$extensions" "exclude" filesOut
    
    # Assert
    actual_files="${filesOut[@]}"
    expected="${expected_files[@]}"
    
    if [ "$expected" == "$actual_files" ]; then
        echo "Test 2 Passed"
    else
        echo "Test 2 Failed"
        echo "Expected: $expected"
        echo "Actual: $actual_files"
    fi

    ## === Test 3: Empty extensions (include everything) === ##
    echo "Running Test 3: Include everything with empty extensions"
    expected_files=("${filesToAnalyze[@]}")
    filesOut=()
    extensions=""
    
    # Act
    filterFilesByExtension filesToAnalyze "$extensions" "include" filesOut
    
    # Assert
    actual_files="${filesOut[@]}"
    expected="${expected_files[@]}"
    
    if [ "$expected" == "$actual_files" ]; then
        echo "Test 3 Passed"
    else
        echo "Test 3 Failed"
        echo "Expected: $expected"
        echo "Actual: $actual_files"
    fi

    ## === Test 4: Invalid mode (should return an error) === ##
    echo "Running Test 4: Invalid include_or_exclude mode"
    filesOut=()
    extensions="md,cpp"
    
    # Act
    output=$(filterFilesByExtension filesToAnalyze "$extensions" "invalid_mode" filesOut 2>&1)
    
    # Assert
    if [[ "$output" == *"ERROR: The fourth parameter must be either 'include' or 'exclude'."* ]]; then
        echo "Test 4 Passed"
    else
        echo "Test 4 Failed"
    fi

    ## === Test 5: Passing an extension with leading dot (should return an error) === ##
    echo "Running Test 5: Extension with leading dot"
    filesOut=()
    extensions=".md"
    
    # Act
    output=$(filterFilesByExtension filesToAnalyze "$extensions" "include" filesOut 2>&1)
    
    # Assert
    if [[ "$output" == *"ERROR: You passed in an extension with a leading dot."* ]]; then
        echo "Test 5 Passed"
    else
        echo "Test 5 Failed output: $output"
    fi
}

# Run the tests
run_tests
