## github.com/giancosta86/main

- **test**: runs all the available tests in the current directory tree.

  ### Inputs

  ### Outputs

  DESCRIBE THE STRUCTURE HERE

- **has-test-files**: outputs `$true` if the current directory tree has test files.

  ### Inputs

  - `includes`: the wildcard to detect test files. **Defaults to**: regular files having **.test.elv** extension.

  - `excludes`: the wildcard to exclude test files from the included set. **Defaults to**: `$nil`.

  ### Outputs

  - `$true` if at least a test file was found.

## github.com/giancosta86/core

- **$tracer**: call its `disable` method to disable all the console output - except the one in the CLI reporter:

  ```elvish
  $core:tracer[disable]
  ```
