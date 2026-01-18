# velvet

_Smooth, functional testing in the Elvish shell_

**velvet** is a minimalist - yet _sophisticated_ - **test framework** and **runner**, enabling its users to _run tests organized in hierarchical structures_ leveraging the _functional programming_ elegance of the [Elvish](https://elv.sh/) shell.

![Logo](logo.png)

## Why Velvet?

I am personally fond of the expressive, **Gherkin**-like syntax supported by testing infrastructures like [Jest](https://jestjs.io/), [Vitest](https://vitest.dev/) and [ScalaTest](https://www.scalatest.org/), but each of them is based on a specific language - which usually doesn't feel as _natural_ as a shell when dealing with _system aspects_ like files, networks or _inter-process communication_.

Given my passion for the [Elvish](https://elv.sh/) shell, I've designed this _testing architecture_ by combining my favorite aspects of such frameworks, while applying my own perspective - especially focused on _cross-technology integration scenarios_.

## Installation

The library can be installed via **epm** - in particular:

```elvish
use epm

epm:install github.com/giancosta86/velvet
```

Even better, if you have [epm-plus](https://github.com/giancosta86/epm-plus), you can run:

```elvish
epm:install github.com/giancosta86/velvet@v3
```

or any other specific Git reference.

## Setup

In **rc.elv**, it is recommended to add the following lines:

```elvish
use github.com/giancosta86/velvet/velvet

var velvet~ = $velvet:velvet~
```

This will make the `velvet` command globally available at the command prompt.

## Writing tests

Tests are defined in **test scripts** - by convention, files having `.test.elv` extension: they are _standard Elvish scripts_ with a fundamental plus - they can also transparently invoke a handful of _additional builtin functions_, injected by Velvet and described in this section.

### Structuring the tests

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

whereas all the other occurrences of `>>` define **sections** - and each section can include _tests_ and _sub-sections_.

**Please, note**: tests can also reside _in the root of the script_ - of course, when they are not contained in another `>>` block.

**Please, note**: the `>>` _function_ - called at the beginning of the line, has _no ambiguity_ with the `>>` _redirection operator_, which always appears _after a command_.

## Test outcome

A test can only have one of _two outcomes_:

- ✅**passed** if its block _ends with no exceptions_

- ❌**failed** if an exception was thrown; in particular, you can fail a test via Elvish's `fail` function, or via one of Velvet's _assertions_.

In the default console reporter, the **test output** - on both _stdout_ and _stderr_ - is displayed, together with the _exception log_, only _if the test fails_.

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

  although, most frequently, you'll use a direct pipe:

  ```elvish
  my-command <arguments> |
    should-be <expected value>
  ```

  #### Equality

  In Velvet, _equality_ is defined as follows:
  - the **default behavior** consists in comparing via `eq` the _minimized representations_ of both operands.

    ```elvish
    # EQUAL!
    put 90 |
      should-be (num 90)
    ```

    **DEFINITION**: the _minimized representation_ for any value is defined as follows:
    - if the value is a **number**, it is the _string_ denoting the number

    - if the value is a **list**, it is a list whose items are the _minimized representations_ of its items

    - if the value is a **map**, it is a map whose keys and values are the _minimized representations_ of the keys and values

    - otherwise, it is _the value itself_

  - if `&strict` is requested, the `eq` function is applied to the pair of values.

    ```elvish
    # NOT EQUAL!
    put 90 |
      should-be &strict (num 90)
    ```

- `should-not-be [&strict] <unexpected>`: if the value passed via pipe (`|`) is equal to the `<unexpected>` argument:
  1. Displays such value

  1. Fails.

  ```elvish
  some-command <arguments> |
    should-not-be 90
  ```

  The input mechanism and the equality logic are the same as those described for `should-be`.

- `should-emit`: ensures that the values passed via pipe (`|`) are _exactly the values_ in the `expected` list; _emission order matters_, unless the `order-key` option is set; on the other hand, the `strict` option works according to the equality rules described within the context of `should-be`.

  The overall command is equivalent to:

  ```elvish
  put [(
    all |
      order &key=$order-key | #Only if &order-key is set
  )] |
    should-be &strict=$strict $expected
  ```

  ##### Example

  ```elvish
  {
    put Hello
    put 90
  } |
    should-emit [
      Hello
      90
    ]

  {
    echo Hello
    echo World
  } |
    should-emit [
      Hello
      World
    ]
  ```

  **Please, note**: for more _granular tests_ focused on the string output of a command, please refer to `create-output-tester`.

- `should-not-emit`: ensures that the values passed via pipe (`|`) _do not include any_ of the values in the `unexpected-values` list; the `strict` option works according to the equality rules described within the context of `should-be`.

  ##### Example

  ```elvish
  {
    put Hello
    put 90
  } |
    should-not-emit [
      World
      4
      SomeOtherValue
    ]
  ```

  **Please, note**: for more _granular tests_ focused on the string output of a command, please refer to `create-output-tester`.

- `fails <block>`: requires `block` to _throw a fail exception_ - via `fail` - outputting the **content** of such failure and _failing if no fail was actually thrown_; if another type of exception is thrown by `block` - for example, a syntax error - it simply passes through. This assertion is preferable to `throws`, which is more general-purpose.

  ##### Example

  ```elvish
  fails {
    fail Dodo
  } |
    should-be Dodo
  ```

  **Please, note**: for more granular tests focused on the output of a command, please refer to `create-output-tester`.

- `should-contain`: receives a _container_ via pipe (`|`) and a `value` as argument, then:
  - if the container is a **string**, ensures that `value` is _a substring_

  - if the container is a **list**, ensures that `value` is _contained in the list_

  - if the container is a **map**, ensures that `value` is _a key of the map_

  - if the container is a **set** from [Ethereal](https://github.com/giancosta86/ethereal), ensures that `value` belongs to the set

  In all cases, the `strict` flag is supported - enabling _strict equality_, as described in the related section above.

  ##### Example

  ```elvish
  # String
  put 'Greetings, magic world!' |
    should-contain magic

  # List
  put [alpha beta gamma] |
    should-contain beta

  # Map
  put [
    &a=90
    &b=92
    &c=95
  ] |
    should-contain b

  # Set
  use github.com/giancosta86/ethereal/v1/set

  all [alpha beta gamma] |
    set:of |
    should-contain beta
  ```

- `should-not-contain`: the negation of `should-contain` - please, see its documentation for aspects such as the supported container types.

  ##### Example

  ```elvish
  # String
  put 'Hello, everybody!' |
    should-not-contain world

  # List
  put [alpha beta gamma] |
    should-not-contain ro

  # Map
  put [
    &a=90
    &b=92
    &c=95
  ] |
    should-not-contain omega

  # Set
  use github.com/giancosta86/ethereal/v1/set

  set:of alpha beta gamma |
    should-not-contain ro
  ```

- `throws <block>`: most general way to assert that `block` _throws an exception_ of any kind - failing if it _completed successfully_. In general, you should use the `fails` assertion, as it focuses on `fail`-based exceptions.

  ```elvish
  # This works fine
  throws {
    fail DODO
  }

  # This will fail, saying a failure was expected!
  throws {
    # This block throws nothing
  }
  ```

  As a plus, the exception itself is _output as a value_, so it can be further inspected via the `exception` module provided by [Ethereal](https://github.com/giancosta86/ethereal).

  ##### Example

  ```elvish
  throws {
    fail DODO
  } |
    exception:is-return |
    should-be $false
  ```

- `fail-test` takes _no arguments_ and _always fails_ - with a predefined message: it's perfect for _quickly sketching out a new test_ in test iterations.

#### Using assertions in shared .elv modules

Assertions are already _injected_ by Velvet into the _default namespace_ when running **.test.elv** test script, but what if one needs to call them from within a **.elv** _utility module_ shared by multiple test scripts?

In such a scenario, one can access _all the assertions_ provided by Velvet simply by importing the `assertions` module from Velvet's package:

```elvish
use github.com/giancosta86/velvet/<VERSION>/assertions
```

then, instead of calling - for example - `should-be`, one can pass through the module namespace: `assertions:should-be`.

### Tools

Tools are _utility constructs_ that can be used in _advanced test scripts_; just like assertions, they are all available in the _default namespace_ of any test scripts - whereas other Elvish scripts can access them via the following _module import_:

```elvish
use github.com/giancosta86/velvet/<VERSION>/tools
```

#### Output tester

Enables _bulk tests_ - more precisely, multiple `should-contain` and `should-not-contain` assertions _on the same command output_ in the form of a **string** containing both **bytes** and **values**, all converted via `to-lines`.

In particular, the `create-output-tester` function creates an object with 2 methods:

- `should-contain-all`: takes a _list_ of **strings** and ensures, via `should-contain`, that the buffered command output contains _each and every_ given string.

- `should-contain-none`: takes a _list_ of **strings** and ensures, via `should-not-contain`, that the buffered command output does **not** contain _each and every_ given string.

Last but not least, the `text` field contains the _buffered output_ as a string.

##### Example

1. Create the output tester, by piping a command output into `create-output-tester`:

   ```elvish
   var tester = (
    {
      put Alpha
      echo Beta
      put Gamma
      echo Delta
    } |
      output-tester:create
   ```

2. Invoke the assertions

   ```elvish
   $tester[should-contain-all] [
     Alpha
     Beta
     Gamma
     Delta
   ]

   $tester[should-contain-none] [
     INEXISTENT
     MISSING
     'SOMETHING ELSE'
   ]
   ```

### Example test script

The following script could be saved as a `.test.elv` file - ready to be run via the `velvet` command.

```elvish
use str

>> 'In arithmetic' {
  >> 'addition' {
    >> 'should work' {
      + 89 1 |
        should-be 90
    }
  }

  >> 'multiplication' {
    >> 'should return just the expected value' {
      var result = (* 15 6)

      put $result |
        should-be 90

      put $result |
        should-not-be 12
    }
  }

  >> 'division' {
    >> 'when dividing by 0' {
      >> 'should fail' {
        throws {
          / 92 0
        } |
          to-string (all)[reason] |
          str:contains (all) divisor |
          should-be $true
      }
    }
  }

  >> 'custom fail' {
    >> 'should be handled and inspectable' {
      fails {
        if (== (% 8 2) 0) {
          fail '8 is even!'
        }
      } |
        should-be '8 is even!'
    }
  }
}
```

## Running tests

To run _all the tests_ within a directory containing _one or more test scripts_ in its _file system tree_, just run this command in the Elvish shell:

> velvet

The command can be customized via a few _optional parameters_:

- `&must-pass`: if _at least one test fails_, or if _at least one test script fails_, the command _throws an exception_. **Default**: disabled.

- `&reporters`: a list of _functions to report the test summary_; each reporter receives a `summary` map object - processing it as needed.

  **Default**: the reporter writing just failed tests to the console with _colors_ and _emojis_.

- `&put`: outputs the summary to the _value channel_. In this case, you'll probably want to set `&reporters=[]` or to a list containing _reporters not writing to the console_ - or simply pipe to `only-values`.

  **Default**: disabled.

- `num-workers`: the (actually maximum) number of _parallel Elvish shells_ executing the test scripts. **Default**: 8.

The _requested script paths_ can also be passed as _variadic arguments_ to the `velvet` command:

```elvish
velvet <script 1> <script 2> ... <script N>
```

otherwise, _all the test scripts located in the directory tree_ below the current working directory will be run.

## Execution flow

![Execution flow](docs/execution-flow.png)

- _Every test script_ runs its tests **sequentially** - in a (virtually) _dedicated shell_: consequently, the _current working directory_ and other global variables can be changed with _no fear of interference_, as long as the script _sets their initial values_ as required.

- _Multiple test scripts_ are usually run **in parallel** - and _all the results are merged_ to a final **summary**, ready to be sent to the _requested reporters_ and/or emitted to Elvish's _value channel_.

  **Please, note**:
  - separate scripts can have _sections with the same titles_ - and _the test results will be merged_ as expected

  - on the other hand, _each test must have a unique path in the test tree_ - that is, the sequence of its **section titles** combined with its own **test title**; otherwise, _all the duplicate occurrences will be merged_ into a _single_ `DUPLICATE!` failing test result

## Predefined reporters

### Console

There are _2 console reporters_, writing the overall **summary** to the _console_ and sharing these presentation rules:

- In each section, **test results** come _before_ **sub-sections**

- **Test results** are shown in _alphabetical order_

- **Sections** are listed in _alphabetical order_, too

- The **stats** are displayed at the end

As for _the differences_ between such reporters:

- the **terse** reporter - at `reporting/console/terse:report~`- only displays _failed tests_. It is the **default** one when running the `velvet` command

- the **full** reporter - `reporting/console/full:report~`- lists _all tests_ - each one with its outcome

### JSON

Writes the passed `summary` object to a given JSON file.

The reporter must be created via a _factory function_ - `reporting/json/report`, which takes in input a file path and emits the actual _reporter function_.

For example:

```elvish
var json-reporter = (json:report $json-report-path)

velvet:velvet &reporters=[$json-reporter]
```

### Reporter spy

A _reporter spy_ is an object providing both a _reporter function_ and a _getter_ emitting the latest **summary** passed to the former function - which can be especially useful when _testing custom reporters_.

It is provided by the `reporting/spy` module, exporting the `create` _factory function_:

```elvish
var spy = (spy:create)
```

which instantiates an object having the following methods:

- `reporter`: the actual function to be passed to the `velvet` command, via its `reporters` list option

- `get-summary`: returns the latest value passed to the associated `reporter`

```elvish
velvet:velvet &reporters=[$spy]

var summary = ($spy[get-summary])
```

## Ethereal namespaces

The [Ethereal](https://github.com/giancosta86/ethereal) library provides a rich set of _general-purpose modules_ for the Elvish shell; Velvet automatically imports some of such modules, to _simplify the development_ of test scripts. For example:

```elvish
# fs is a module from Ethereal
# that is automatically provided by Velvet.
fs:with-temp-file { |temp-path|
  echo alpha >> $temp-path
  echo beta >> $temp-path

  slurp < $temp-path |
    should-be "alpha\nbeta\n"
}
```

The **available namespaces** at present are:

- **command**
- **edit**
- **exception**
- **fs**
- **lang**
- **map**
- **resources**
- **seq**
- **set**
- **string**

Please, refer to [Ethereal](https://github.com/giancosta86/ethereal)'s documentation for further details.

## Frequently asked questions

### Are there setup and teardown?

Nope, because **velvet** is designed to be _minimalist_ - and you can _achieve the same results_ via the Elvish language:

- **setup** can be replaced by _a factory function_ - often with _closures_

- **teardown** can be replaced by _a dedicated higher-order function_ with a _block argument_ - executing it within a `try`/`finally` structure or in a `defer`-based context

### `echo`, `print`, `pprint` and other functions have no output: why?

In the _default console reporter_, **successful tests do not output their stdout/stderr**, by design.

Should you need further inspection, you can make the test fail just by adding a call to `fail-test` - which takes no arguments.

### Is there a recommended style to structure the tests?

The user is _absolutely free_: the system only provides the `>>` function to _create nodes in the test tree_: all the rest depends on the specific _expressive requirements_ - which _could change from one test script to another_ or even _within the same script_.

### Why are the tests not in the same order as in my script?

Because they are _alphabetically sorted_ by the default console reporter - a choice stemming from the fact that, in Velvet, _sections can span multiple test scripts_, as required by the _testing style_ or by the _isolation needs_ in terms of global variables like the _current working directory_.

## Credits

Logo image generated by **ChatGPT** and manually enhanced with **Google Fonts** and **GIMP**.

## See also

- [Ethereal](https://github.com/giancosta86/ethereal) - _Elegant utilities for the Elvish shell_

- [epm-plus](https://github.com/giancosta86/epm-plus) - _Package versioning for epm in Elvish_

- [Elvish](https://elv.sh/)
