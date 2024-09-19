#!/bin/bash
source ../imports/process_directory.sh
## set -x
## === Arrange === ## 

# Cleanup if anything exists from prior runs 
if [ -d "_temp_/process_dir" ]; then
  rm -rf "_temp_/process_dir"
  echo "Arrange: Removed old temp dir"
fi

mkdir -p "_temp_/process_dir"
cd "_temp_/process_dir/" || exit
# Make a relatively complicated structure 
mkdir -p "root/a/a1"
mkdir -p "root/b/b1"
mkdir -p "root/b/b2"
mkdir -p "root/b/b2/leaf"

echo "tt" > "./root/a/test.txt"
echo "a1f" > "./root/a/a1/a1read.md"
echo "b1" > "./root/b/b1/b1f.md"
echo "b1b" > "./root/b/b1/b1b.md"

dir="$(pwd)/root"
## === Act === ## 
process_directory $dir "md txt" "include"

## === Assert === ## 
echo "Failed Failed Failed -- Haven't even finsihed writing the function yet"




#Added this because some syntax errors can cause the script to silently stop executing
echo "End of Tests: $(basename "$0")" 