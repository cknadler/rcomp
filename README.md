# RComp [![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/cknadler/rcomp) [![Dependency Status](https://gemnasium.com/cknadler/rcomp.png)](https://gemnasium.com/cknadler/rcomp) [![Build Status](https://travis-ci.org/cknadler/rcomp.png)](https://travis-ci.org/cknadler/rcomp)


RComp is a simple framework for testing command line application output. It works by passing a specified command tests (files) by argument and comparing the result with expected output.

## Installation

```
$ gem install rcomp
```

## Usage

```
$ rcomp
Tasks:
  rcomp generate     # Generate expected output for all tests
  rcomp help [TASK]  # Describe available tasks or one specific task
  rcomp init         # Setup rcomp test directory
  rcomp test         # Run all tests
  rcomp version      # Prints RComp's version information
```

## Setup

In your project root directory, run:

```
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

A simple RComp suite might look something like:

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

All custom configuration is stored in `.rcomp` as YAML

<table>
  <th>Setting</th><th>Config</th><th>Default</th><th>Description</th>
  <tr>
    <td>command</td>
    <td><code>command: [COMMAND]</code></td>
    <td></td>
    <td>Command RComp will run tests with</td>
  </tr>
  <tr>
    <td>directory</td>
    <td><code>directory: [DIRECTORY]</code></td>
    <td><code>rcomp</code></td>
    <td>Directory RComp will store tests, results and expected in</td>
  </tr>
  <tr>
  	<td>ignore</td>
  	<td>
  	  <code>
  	    ignore:
  	  	  - [PATTERN]
  	  </code>
  	</td>
  	<td></td>
  	<td>List of patterns RComp will ignore when finding tests</td>
  </tr>
  <tr>
  	<td>timeout</td>
  	<td><code>timeout: [TIMEOUT]</code></td>
  	<td><code>5</code></td>
  	<td>Test execution time limit (seconds)</td>
  </tr>
</table>

## Aliases

<table>
  <th>Task</th><th>Alias</th>
  <tr>
    <td><code>test</code></td>
    <td><code>t</code></td>
  </tr>
  <tr>
    <td><code>generate</code></td>
    <td><code>g</code></td>
  </tr>
  <tr>
    <td><code>version</code></td>
    <td><code>-v</code><code>--version</code></td>
  </tr>
</table>

## Copyright

Copyright (c) 2012 Chris Knadler. See LICENSE for details.
