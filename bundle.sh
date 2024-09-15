#!/bin/bash

# Define paths
MAIN_FILE="main.sh"
OUTPUT_FILE="catalytics.sh"
IMPORTS_DIR="./imports"

# Function to remove lines before the first function definition
trim_before_first_function() {
  awk '/^ *[a-zA-Z_][a-zA-Z_0-9]* *\(/ {found=1} found {print}' "$1"
}

# Start by creating the output file
echo "Creating bundled script: $OUTPUT_FILE"
> $OUTPUT_FILE  # Clear the output file if it exists

# Append the content of each import file after trimming
echo "Appending imports from $IMPORTS_DIR"
for file in "$IMPORTS_DIR"/*.sh; do
  echo "# === Start of $file ===" >> $OUTPUT_FILE
  trim_before_first_function "$file" >> $OUTPUT_FILE
  echo "# === End of $file ===" >> $OUTPUT_FILE
done

# Append the main.sh file last
echo "Appending main.sh"
echo "# === Start of main.sh ===" >> $OUTPUT_FILE
cat $MAIN_FILE >> $OUTPUT_FILE
echo "# === End of main.sh ===" >> $OUTPUT_FILE

# Make the output file executable
chmod +x $OUTPUT_FILE

echo "Bundling complete! You can now run $OUTPUT_FILE independently."
