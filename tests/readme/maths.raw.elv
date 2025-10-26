use path
use ../../assertions
use ../../main
use ../../utils/raw

raw:suite 'Running the README test' { |test~|
  tmp pwd = (path:join tests readme)

  test 'Checking the stats' {
    main:velvet &must-pass &put &reporters=[] |
      put (all)[stats] |
      assertions:should-be [
        &total=4
        &passed=4
        &failed=0
      ]
  }
}