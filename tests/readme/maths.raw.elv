use path
use ../../assertions
use ../../main
use ../../utils/raw

raw:suite 'README tests' { |test~|
  tmp pwd = (path:join tests readme)

  test 'Must run successfully' {
    main:velvet &must-pass &put &reporters=[] |
      put (all)[stats] |
      assertions:should-be [
        &total=4
        &passed=4
        &failed=0
      ]
  }
}