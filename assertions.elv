use str
use github.com/giancosta86/aurora-elvish/console
use github.com/giancosta86/aurora-elvish/command
use github.com/giancosta86/aurora-elvish/string

fn assert { |predicate|
  if (not $predicate) {
    fail 'Assertion failed!'
  }
}

fn expect-crash { |block|
  try {
    $block
  } catch e {
    put $e
  } else {
    fail 'The given code block did not fail!'
  }
}

fn fail-test {
  fail 'TEST SET TO FAIL'
}

fn -print-expected-and-actual { |inputs|
  var expected-description = $inputs[expected-description]
  var expected = $inputs[expected]

  var actual-description = $inputs[actual-description]
  var actual = $inputs[actual]

  console:print (styled $expected-description': ' green bold)
  console:pprint $expected

  console:print (styled $actual-description': ' red bold)
  console:pprint $actual
}

fn should-be { |&strict=$false expected|
  one | each { |actual|
    if $strict {
      if (not-eq $expected $actual) {
        -print-expected-and-actual [
          &expected-description='Expected (strict)'
          &expected=$expected
          &actual-description='Actual (strict)'
          &actual=$actual
        ]

        fail 'strict should-be assertion failed'
      }
    } else {
      var expected-string = (string:get-minimal $expected)
      var actual-string = (string:get-minimal $actual)

      if (not-eq $expected-string $actual-string) {
        -print-expected-and-actual [
          &expected-description='Expected'
          &expected=$expected
          &actual-description='Actual'
          &actual=$actual
        ]

        fail 'should-be assertion failed'
      }
    }
  }
}
