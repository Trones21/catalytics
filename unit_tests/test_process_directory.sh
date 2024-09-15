source ../imports/process_directory.sh

## === Arrange === ## 

# Cleanup if anything exists from prior runs 
if [ -d "_temp_/process_dir" ]; then
  rm -rf "_temp_/process_dir"
fi

mkdir "_temp_/process_dir"
cd "_temp_/process_dir"
# Make a relatively complicated structure 
mkdir -p "root/a/a1"
mkdir -p "root/b/b1"
mkdir -p "root/b/b2"
mkdir -p "root/b/b2/leaf"

dir="$(pwd)/root"
## === Act === ## 
process_directory $dir ".md" "include" 0 0 0

## === Assert === ## 
echo "Failed Failed Failed -- Haven't even finsihed writing the function yet"