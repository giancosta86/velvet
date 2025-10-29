# velvet

_Smooth, functional testing in the Elvish shell_

**velvet** is a minimalist - yet _sophisticated_ - **test framework** and **runner**, enabling its users to _run tests organized in hierarchical structures_ leveraging the _functional programming_ elegance of the [Elvish](https://elv.sh/) shell.

![Console summary](docs/console-summary.png)

## Why Velvet?

I am personally fond of the expressive, **Gherkin**-like syntax that can be found in test software like [Jest](https://jestjs.io/), [Vitest](https://vitest.dev/) and [ScalaTest](https://www.scalatest.org/), but each of them is based on a specific language - which usually doesn't feel as natural as a shell when dealing with **system programming** like file, network or process operations.

Given my passion for the [Elvish](https://elv.sh/) shell, I've designed this testing infrastructure by combining my favorite aspects of such frameworks, while applying my own perspective - especially focusing on _cross-technology, integration scenarios_.

## Installation

Velvet can be installed via **epm** - in particular:

```elvish
use epm

epm:install github.com/giancosta86/velvet
```

## Setup

In **rc.elv**, it is recommended to add the following lines:

```elvish
use github.com/giancosta86/velvet/main velvet

var velvet~ = $velvet:velvet~
```

This will make the `velvet` command globally available at the command prompt.

## Writing tests

Tests are defined in **test scripts** - by convention, files having `.test.elv` extension: they are _standard Elvish scripts_ that can also transparently invoke a handful of _additional builtin functions_, injected by Velvet and described below.

### Defining the test structure

The `>>` function is the basic building block for _defining the test tree_ - adopting _a Gherkin-like descriptive notation_:

```elvish
>> 'First component' {
  >> 'division operation' {
    >> 'when divisor is not 0' {
      >> 'should return value' {
        # Test code goes here
      }
    }

    >> 'when divisor is 0' {
      >> 'should crash' {
        # Test code goes here
      }
    }
  }
}

>> 'Second component' {
  >> 'other operation' {
    >> 'should work' {
      # Test code goes here
    }
  }
}
```

The innermost calls of `>>` define **tests**, which are the leaves in a tree of **sections**; in the example above, the tests are:

- **should return value**

- **should crash**

- **should work**

whereas the sections are:

- **First component**

- **division operation**

- **when divisor is not 0**

- **when divisor is 0**

- **Second component**

- **other operation**

**Please, note**: tests can also reside in the root of the script - simply when they are not contained in another `>>` block.

**Please, note**: the `>>` _function_ - called at the beginning of the line, has _no ambiguity_ with the `>>` _redirection operator_, which always appears after a command.

## Test outcome

A test can only have two outcomes:

- ✅**passed** if its block ends with no exception

- ❌**failed** if an exception was thrown; in particular, you can fail a test via Elvish's `fail` function, or via one of Velvet's _assertions_.

The **test output** - on both _stdout_ and _stderr_ - is displayed, together with the _exception log_, only if the test fails.

### Assertions

- `should-be [&strict] <expected>`: if the value passed via pipe (`|`) is not equal to the `<expected>` argument:

  1. Displays both values

  1. If the `diff` command is available on the system, also shows their differences

  1. Fails.

  To test a single variable, you can prepend the `put` function:

  ```elvish
  put $my-variable |
    should-be 90
  ```

  although, most frequently, you'll use a direct pipe

  ```elvish
  my-command <arg 1> <arg 2> ... <arg N> |
    should-be <expected value>
  ```

  #### Equality

  In Velvet, _equality_ is defined as follows:

  - if `&strict` is requested, the `eq` function is applied to the pair of values.

    ```elvish
    # This assertion fails!
    put 90 |
      should-be &strict (num 90)
    ```

  - otherwise, the default behavior consists in comparing the _recursive minimalist string representations_ of both operands.

    ```elvish
    # This succeeds!
    put 90 |
      should-be &strict (num 90)
    ```

- `should-not-be [&strict] <unexpected>`: if the value passed via pipe (`|`) is equal to the `<unexpected>` argument:

  1. Displays such value

  1. Fails.

  ```elvish
  some-command |
    should-not-be 90
  ```

  The `&strict` equality flag works precisely like described above.

- `throws <block>`: requires `block` to _throw an exception_ - failing if it completed successfully.

  ```elvish
  # This works fine
  throws {
    fail DODO
  }

  # This will fail, saying a failure was expected!
  throws {
    # This blocks throws nothing
  }
  ```

  As a plus, the exception itself is output as a value, so it can be further inspected - especially via `get-fail-content`, which returns the value (usually a message string) passed to the `fail` command, or `$nil` otherwise.

  ```elvish
  throws {
    fail DODO
  } |
    get-fail-content |
    should-be DODO
  ```

- `fail-test` takes no arguments and _always fails_ - with a predefined message: it's perfect for quickly sketching up a new test in test iterations.

## Running tests

To run all the tests within a directory containing one or more test scripts in its tree, just run this command in the Elvish shell:

> velvet

The command can be customized via a few _optional parameters_:

- `&must-pass`: if at least one test fails, the command throws an exception. **Default**: disabled.

- `&reporters`: an array of functions to report the test summary; each reporter receives a `summary` object - with no additional constraints. **Default**: a reporter writing to the console with _colors_ and _emojis_.

- `&put`: outputs the summary to Elvish's value channel. In this case, you'll probably want to set `&reporters=[]` - or to reporters not writing to the console. **Default**: disabled.

- `num-workers`: the (actually maximum) number of parallel Elvish shells executing test scripts. **Default**: 8.

The script paths can also be passed as _variadic arguments_ to the `velvet` command:

```elvish
velvet <script 1> <script 2> ... <script N>
```

otherwise, all the test scripts located in the directory tree below the current working directory will be run.

## Execution flow

![Execution flow](docs/execution-flow.png)

- Every test script runs its tests **sequentially** - in a (virtually) _dedicated shell_: consequently, the _current working directory_ and other global variables can be changed with no fear of interference.

- Multiple test scripts are usually run _in parallel_ - and all the results are merged in the end, ready to be sent to the requested reporters and/or emitted to Elvish's value channel.

  **Please, note**:

  - separate scripts can have _sections with the same titles_ - and the test results will be merged

  - on the other hand, _tests must have unique titles_ - or they will be merged into a `DUPLICATE!` test result

## Credits

Logo image generated by **ChatGPT** and enhanced with **Google Fonts** and **GIMP**.

## See also

- [Elvish](https://elv.sh/)
