use path
use str
use github.com/giancosta86/ethereal/v1/string
use ./reporting/console/full
use ./reporting/console/terse
use ./velvet

>> 'README tests' {
  tmp pwd = (path:join tests readme)

  >> 'execution and stats' {
    velvet:velvet &flawless &emit-summary &reporters=[] |
      put (all)[stats] |
      should-be [
        &total=4
        &passed=4
        &failed=0
      ]
  }

  >> 'console reporter log' {
    fn assert-readme-log { |reporter expected-basename|
      var expected-log = (slurp < $expected-basename)

      velvet:velvet &reporters=[$reporter] |
        slurp |
        string:unstyled (all) |
        str:trim-space (all) |
        should-be $expected-log
    }

    >> 'terse' {
      assert-readme-log $terse:report~ terse.log
    }

    >> 'full' {
      assert-readme-log $full:report~ full.log
    }
  }
}