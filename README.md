# Catalytics

Content Analytics for your Docusaurus site (...really any directory though)

## Description

Originally developed for analyzing the amount of content by category in my new docusaurus based portfolio site, this script effectively works on any directory. The output file is json and can be imported into any popular analytics tools - 

## Running

Start here: `source catalytics.sh -h`

### Examples

Run on the "tests" directory
`source catalytics.sh --dir ./tests/`

## Tests

Currently we just have a full end-to-end test. test runner.sh that runs the script against an unchanging directory, the expected output has been created by manually counting the files and folders.

Run with: `source test_runner.sh`

## To Do

- get test working
- exclude _category_.json from counts

### Execution Flags

- `-ext_excl / -ext_incl <extensions including dot>`: Exclude / include specific file types

#### Post Run Analysis

- `-o | --overall <name of output file>`: Creates a top level json file that aggregates the information for the entire directory.

Shape of this file is wip. Now its a question of how much to parse here vs. letting an analytics tool do it.

```json
{
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

- count_by_type: List counts of files

## Ideas

## Docusaurus Specific

### React vizualization Components

- Add some vizualization components that take the overall file as an input.  

### Generic
- -rm_ch | --remove-children: Removes the _category_.json files
  * This SHOULD NOT be run in a docusaurus context because you will lose the other parts of your _category.json_s... maybe we back them up or well you should be using git anyhow....