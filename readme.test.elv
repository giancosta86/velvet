use path
use str
use github.com/giancosta86/ethereal/v1/string
use ./reporting/console/full
use ./velvet

>> 'README tests' {
  tmp pwd = (path:join tests readme)

  >> 'execution and stats' {
    velvet:velvet &must-pass &put &reporters=[] |
      put (all)[stats] |
      should-be [
        &total=4
        &passed=4
        &failed=0
      ]
  }

  >> 'default console reporter log' {
    var expected-log = (slurp < terse.log)

    velvet:velvet |
      slurp |
      string:unstyled (all) |
      str:trim-space (all) |
      should-be $expected-log
  }

  >> 'full console reporter log' {
    var expected-log = (slurp < full.log)

    velvet:velvet &reporters=[$full:report~] |
      slurp |
      string:unstyled (all) |
      str:trim-space (all) |
      should-be $expected-log
  }
}