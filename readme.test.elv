use path
use str
use github.com/giancosta86/ethereal/v1/string
use ./main

>> 'README tests' {
  tmp pwd = (path:join tests readme)

  >> 'execution and stats' {
    main:velvet &must-pass &put &reporters=[] |
      put (all)[stats] |
      should-be [
        &total=4
        &passed=4
        &failed=0
      ]
  }

  >> 'console reporter log' {
    var expected-log = (slurp < maths.log)

    main:velvet |
      slurp |
      string:unstyled (all) |
      str:trim-space (all) |
      should-be $expected-log
  }
}