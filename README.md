# Catalytics

Content Analytics for your Docusaurus site (...really any directory though)

## Description

Originally developed for analyzing the amount of content by category in my new docusaurus based portfolio site, this script effectively works on any directory. The output file is json and can be imported into any popular analytics tools - 

## Running

Start here: `source catalytics.sh -h`

### Examples

Run on the "e2e_test" directory
`source catalytics.sh --dir ./e2e_test/` 

## Tests

### End to End
e2e_test.sh that runs the script against an unchanging directory, the expected output has been created by manually counting the files and folders.

Run with: `source e2e_test.sh`

### Unit Tests

Just a few in place 

## To Do

- get e2e_test working
- iN PROGRESS - exclude _category_.json from counts
- post run analysis

### Execution Flags

- `-ext_excl / -ext_incl <extensions including dot>`: Exclude / include specific file types

#### Post Run Analysis

- `-o | --overall <name of output file>`: Creates a top level json file that aggregates the information for the entire directory.

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

- -rm_ch | --remove-children: Removes the _category_.json files
  * This SHOULD NOT be run in a docusaurus context because you will lose the other parts of your _category.json_s... maybe we back them up or well you should be using git anyhow....

- create a cron job to do this analysis on a regular basis? 
  - then would I append to the overall json or make a new file each time it is run?
    - My gut feel is that analytics tools will be better able to handle a single large json 
  - If no change, do we still write the file?
    - yes, its usually easier to work with when you have that "filler" data in Tableau... lets Add another top level property `"diff_to_previous_run":"true/false",`