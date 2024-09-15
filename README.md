# Catalytics

Content Analytics for your Docusaurus site (...really any directory though)

## Description

Originally developed for analyzing the amount of content by category in my new docusaurus based portfolio site, this script effectively works on any directory. The output file is json and can be imported into any popular analytics tools.

Note: I know this doesn't follow bash variable naming conventions, and there are several things that could likely be done better with pre-existing libraries: tests, path resolution, etc. , as well as things you would likely never do e.g. writing a test case for function that is literally just `wc -m < "$file" | tr -d ' '` but as this little project expanded it offered a nice opportunity to master bash scripting syntax.

Right tool for the job... probably not, but hey I'm solidifying my knowledge of bash scripting (which up until now I've only ever done super basic stuff with).

Its also nice to build everything from scratch because you dont have to look anything up (e.g. test runner syntax)

## Running

Start here: `bash catalytics.sh -h`

### Examples

#### Run on the "e2e_test" directory
`bash catalytics.sh --dir ./e2e_test/`

#### List all the file extensions to be found in a directory
`bash catalytics.sh --dir "e2e_test" -list_ext`

## Tests

### End to End
e2e_test.sh that runs the script against an unchanging directory, the expected output has been created by manually counting the files and folders.

Run with: `bash e2e_test.sh`

### Unit Tests

#### Background 
Started with no unit tests...
refactor filterfiles func to take a list with paths in multiple directories and wrap in a new func... so a couple of unit tests...
and some more to verify correct recursive post order processing...  
and some simple tests for peace of mind... (ignoreCateogryJson... later on maybe we make this a CLI param to exclude by path/filename)
ok well we might as well write a "runner" so we dont have to run these all individually  
lol

**It's best to run both the runner and individual unit tests while in the unit_tests directory... some tests have some code to deal with a different pwd, but not all of them do, so you might get odd behavior if you run from a different location** 

#### Run all tests included in [runner.sh](unit_tests/runner.sh)

runner.sh is meant to be your "workshop" for determining which tests to run.
I usually pipe to colorize_output to make it easier to recognize pass/fail

```bash
bash runner.sh # run just the tests specified in runner.sh
bash runner.sh -a # Match on test_,  Run all
```

#### Running an Individual Test

Just run the file:

```bash
bash test_catalyticsfuncs.sh
```

Some tests have a -v flag which outputs more information (for example: the actual and expected values even for passing tests)

##### Running an Individual Test with Colorized Output

To run an individual test and apply the `colorize_output` function, use:

```bash
bash test_catalyticsfuncs.sh | colorize_output
```

Before you can use `colorize_output`, it needs to be available in your current shell session. To do that, run:

```bash
source runner.sh  # This loads colorize_output into your current shell
```

You can verify that the function is available by using `declare`:

```bash
declare -f colorize_output  # This will display the function definition if it's loaded correctly
```

### Bundling

After makes changes to the code, you need to run the [bundler](bundle.sh) for them to be reflected in [catalytics.sh](catalytics.sh)

```bash
bash bundle.sh
```

## To Do

- finish test_catalyticsFunc.sh
  - It's failing to write the json again (added rundate), but the direct function itself is fine.. catalyticsfunc is the caller.
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