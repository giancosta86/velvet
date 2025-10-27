use path
use str
use ../../assertions
use ../../main
use ../../utils/raw
use ../../utils/string

raw:suite 'README tests' { |test~|
  tmp pwd = (path:join tests readme)

  test 'Execution and stats' {
    main:velvet &must-pass &put &reporters=[] |
      put (all)[stats] |
      assertions:should-be [
        &total=4
        &passed=4
        &failed=0
      ]
  }

  test 'Console reporter log' {
    var expected-log = (slurp < maths.log)

    main:velvet |
      slurp |
      string:unstyled (all) |
      str:trim-space (all) |
      assertions:should-be $expected-log
  }
}