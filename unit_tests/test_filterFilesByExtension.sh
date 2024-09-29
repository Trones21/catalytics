#!/bin/bash

source ../imports/helpers.sh

echo 

## === Tests === ##

run_tests() {

    ## === Case 1: Include only .md and .cpp files === ##
    echo "Running Case 1: Include only .md and .cpp files"
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
        echo "Case 1 Passed"
    else
        echo "Case 1 Failed"
        echo "Expected: $expected"
        echo "Actual: $actual_files"
    fi

    ## === Case 2: Exclude .md and .cpp files === ##
    echo "Running Case 2: Exclude .md and .cpp files"
    expected_files=("/path/to/file1.txt" "/path/to/file3.sql")
    filesOut=()
    extensions="md,cpp"
    
    # Act
    filterFilesByExtension filesToAnalyze "$extensions" "exclude" filesOut
    
    # Assert
    actual_files="${filesOut[@]}"
    expected="${expected_files[@]}"
    
    if [ "$expected" == "$actual_files" ]; then
        echo "Case 2 Passed"
    else
        echo "Case 2 Failed"
        echo "Expected: $expected"
        echo "Actual: $actual_files"
    fi

    ## === Case 3: Empty extensions (include everything) === ##
    echo "Running Case 3: Include everything with empty extensions"
    expected_files=("${filesToAnalyze[@]}")
    filesOut=()
    extensions=""
    
    # Act
    filterFilesByExtension filesToAnalyze "$extensions" "include" filesOut
    
    # Assert
    actual_files="${filesOut[@]}"
    expected="${expected_files[@]}"
    
    if [ "$expected" == "$actual_files" ]; then
        echo "Case 3 Passed"
    else
        echo "Case 3 Failed"
        echo "Expected: $expected"
        echo "Actual: $actual_files"
    fi

    ## === Case 4: Invalid mode (should return an error) === ##
    echo "Running Case 4: Invalid include_or_exclude mode"
    filesOut=()
    extensions="md,cpp"
    
    # Act
    output=$(filterFilesByExtension filesToAnalyze "$extensions" "invalid_mode" filesOut 2>&1)
    
    # Assert
    if [[ "$output" == *"ERROR: The third parameter must be either 'include' or 'exclude'"* ]]; then
        echo "Case 4 Passed"
    else
        echo "Case 4 Failed - output: $output"
    fi

    ## === Case 5: Passing an extension with leading dot (should return an error) === ##
    echo "Running Case 5: Extension with leading dot"
    filesOut=()
    extensions=".md"
    
    # Act
    output=$(filterFilesByExtension filesToAnalyze "$extensions" "include" filesOut 2>&1)
    
    # Assert
    if [[ "$output" == *"ERROR: You passed in an extension with a leading dot."* ]]; then
        echo "Case 5 Passed"
    else
        echo "Case 5 Failed output: $output"
    fi
}

# Run the tests
run_tests


#Added this because some syntax errors can cause the script to silently stop executing
echo "End of Tests: $(basename "$0")" 
