# Catalytics

Content Analytics for your Docusaurus site (...really any directory though)

## Description

Originally developed for analyzing the amount of content by category in my new docusaurus based portfolio site, this script effectively works on any directory. The output file is json and can be imported into any popular analytics tools - 

## Running

Start here: `source catalytics.sh -h`

### Examples

#### Run on the "e2e_test" directory
`source catalytics.sh --dir ./e2e_test/`

#### List all the file extensions to be found in a directory
`source catalytics.sh --dir "e2e_test" -list_ext`

## Tests

### End to End
e2e_test.sh that runs the script against an unchanging directory, the expected output has been created by manually counting the files and folders.

Run with: `source e2e_test.sh`

### Unit Tests

Started with no unit tests...
refactor filterfiles func to take a list with paths in multiple directories and wrap in a new func... so a couple of unit tests...
and some more to verify correct recursive post order processing...  
and some simple tests for peace of mind... (ignoreCateogryJson... later on maybe we make this a CLI param to exclude by path/filename)
ok well we might as well write a "runner" so we dont have to run these all individually  
lol

## To Do

- finish test_catalyticsFunc.sh
  - catalytics func needs to "return" file and char counts so they can be used recursively (post-order) in process_directory
  - we need to assert on 2 things:
    - 1. _category_.json counts are correct
    - 2. arrays passed by ref properly updated  (childFileCounts, childCharCounts) 
- write test_process_directory.sh - The key thing here is that I must ensure the recursive addition of child file counts and char counts is working correctly
- get e2e_test working 
  - try running with various parameters as well, e.g. include / exclude, but use the same sampleDir
- post run analysis

### Execution Flags

- `--ext_excl / --ext_incl <extensions including dot>`: Exclude / include specific file types


#### Post Run Analysis

- `--o | --overall <name of output file>`: Creates a top level json file that aggregates the information for the entire directory.

Shape of output file:

```json
{
  "date_run": "YYYYMMDD:HH:ss",
  "diff_to_previous_run":"true/false",
  "files":[
      {
    "path":"",
    "name": "",
    "extension": "",
    "charCount": "",
      }, 
    ...],
  "dirs":[
    "level 1 <top>":[
      {
        "path":"",
        "fileCountSelf":"<count of files immediately in this dir, no subdirs>",
        "charCountSelf":"<count of characters in files immediately in this dir, no subdirs>",
        "fileCountTotal":"<unlike self this includes all subdirs>",
        "charCountTotal":"<unlike self this includes all subdirs>",
      }.
      ...
    ]
    "level 2": [...]
    <all the way to deepest leaf level>
  ]  
}
```

## Ideas

## Docusaurus Specific

### React vizualization Components

- Add some vizualization components that take the overall file as an input.  

### Generic

- Consider making a map and filter function that i can pass my specific logic to
- Quick analysis flags: Adding a flag to look at overall.json
- count_by_type: List counts of files

- create a cron job to do this analysis on a regular basis? 
  - then would I append to the overall json or make a new file each time it is run?
    - My gut feel is that analytics tools will be better able to handle a single large json 
  - If no change, do we still write the file?
    - yes, its usually easier to work with when you have that "filler" data in Tableau... lets Add another top level property `"diff_to_previous_run":"true/false",`

- Add CLI param/s for include/exclude by path (or just filename??)
- -rm_ch | --remove-children: Removes the _category_.json files
  * This SHOULD NOT be run in a docusaurus context because you will lose the other parts of your _category.json_s... maybe we back them up or well you should be using git anyhow....