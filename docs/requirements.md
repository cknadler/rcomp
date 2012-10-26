#rcomp requirements

Rcomp is intended to be an extremely simple testing framework for command line applications. It should be as simple as passing rcomp an executable and letting it diff the output of the executable given an input file (the test) vs. expected output. The "tests" are simply input files that you pass to executable.

### Manual

Running without arguments

```
$ rcomp

Example usage:
	rcomp test --all
	rcomp test TEST_NAME
	
	rcomp test -v --all
	rcomp test -v TEST_NAME
	
	rcomp vdiff TEST_NAME
	
	rcomp gen TEST_NAME
	rcomp gen --all
	rcomp gen --overwrite-all
	
	rcomp print TEST_NAME
	rcomp print --result TEST_NAME
	
Help:
	man rcomp
```

Running all tests

Number of dots coresponds to number of tests. Each failed test is highlighted red. Passed tests are highlighted green.

```
$ rcomp test --all

Running tests: spec/rcomp/*
. . . .

build-env3 - failed

1 test failed
```

Running a single test

```
$ rcomp test build-env1

Running test: spec/rcomp/build-env1

Test passed!
```

Running all tests verbose

```
$ rcomp test -v --all

Running tests:

build-env1 - passed
build-env2 - passed
build-env3 - failed
build-env4 - passed

1 test failed
```

Running single test verbose

```
$ rcomp test -v build-env1

Running test: build-env1

Contents:
	
	# hkl
	# build-env1
	
	puts 1 + 1
	
	puts 1 + 2
	
Output:

	2
	3
	
Expected:

	2
	3
	
Test passed!
	
```
