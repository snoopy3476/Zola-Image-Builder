# Optimizer Pass

  - Place **executable** scripts inside this directory to run on build

  - All optimizer scripts are run in ascending order of their filenames
    - e.g) `00_first_script` > `10_second_script` > `20_third_script` > ...

  - Directory structure of current working directory, when each script is running:
    - Directory structure
      - `./input`: Directory that containing files before current optimizer stage
      - `./output`: Directory to place the results of optimizer output
    - Examples of optimizer file contents
      - `cp -af ./input/. ./output`:
        Just pass input as output, without any modification
      - `cp -af ./input/. ./output && gzip -krf9 ./output`:
        Add new gzip compressed results as `filename.gz` to each input file
