use path
use str
use github.com/giancosta86/ethereal/v1/string
use ./reporting/console/full
use ./reporting/console/terse
use ./velvet

>> 'README tests' {
  tmp pwd = (path:join tests readme)

  >> 'should run flawlessly' {
    velvet:velvet &flawless
  }

  >> 'console reporter log' {
    fn assert-readme-log { |reporter expected-basename|
      var expected-log = (slurp < $expected-basename)

      capture {
        velvet:velvet &reporters=[$reporter]
      } |
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