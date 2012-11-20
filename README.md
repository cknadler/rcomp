# RComp [![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/cknadler/rcomp) [![Dependency Status](https://gemnasium.com/cknadler/rcomp.png)](https://gemnasium.com/cknadler/rcomp) [![Build Status](https://travis-ci.org/cknadler/rcomp.png)](https://travis-ci.org/cknadler/rcomp)


RComp is a simple test framework for testing command line applications output. It works by passing a specified command tests (files) by argument and comparing the result with expected output.

## Installation

```
$ gem install rcomp
```

## Usage
```
$ rcomp
Tasks:
  rcomp generate             # Generate expected output for all tests
  rcomp help [TASK]          # Describe available tasks or one specific task
  rcomp init                 # Setup rcomp test directory
  rcomp set_command COMMAND  # Sets the command RComp will run tests with
  rcomp set_directory PATH   # Set the directory RComp will store files
  rcomp test                 # Run all tests
```

## Setup

In your project root directory, run:

```
$ rcomp set-command ./some-executable
$ rcomp init
```

Then create some tests in `rcomp/tests`

## Structure
After running `rcomp init` the following directories are created by default:

```
.
|--rcomp
|----tests
|----expected
|----results
```

### tests
Stores test files. All subdirectories will be searched for tests.

### expected
Stores the expected output of tests. Format is `testname.out` for `stdout` and `testname.err` for `stderr`.

### results
Managed by RComp. Stores the results of your most recent test suite run.

---

A simple RComp suite might look something like this:

```
.
|--rcomp
|----tests
|------test1.test
|------dir
|--------test2.test
|----expected
|------test1.out
|------dir
|--------test2.out
|--------test2.err
```

## Configuration
All custom configuration is stored in a `.rcomp` file as YAML

| Setting | Config | Default | Description |
|-|-|-|
| command | `command: [COMMAND]` | | Command RComp will run tests with  |
| directory | `directory: [DIRECTORY]` | `rcomp` | Directory RComp will store tests, results and expected |

## Aliases
| Task | Alias |
|-|-|
| `test` | `t` |
| `generate` | `g` |
| `set-command` | `c` |
| `set-directory` | `d` |


## Copyright

Copyright (c) 2012 Chris Knadler. See LICENSE for details.
