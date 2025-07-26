use str
use github.com/giancosta86/aurora-elvish/command
use github.com/giancosta86/aurora-elvish/string
use ./core

fn -print-expected-and-actual { |inputs|
  var expected-description = $inputs[expected-description]
  var expected = $inputs[expected]

  var actual-description = $inputs[actual-description]
  var actual = $inputs[actual]

  $core:tracer[print] (styled $expected-description': ' green bold)
  $core:tracer[pprint] $expected

  $core:tracer[print] (styled $actual-description': ' red bold)
  $core:tracer[pprint] $actual
}

fn should-be { |&strict=$false expected|
  #TODO! Check this "one"
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

fn expect-crash { |block|
  try {
    $block
  } catch e {
    put $e
  } else {
    fail 'The given code block did not fail!'
  }
}

fn expect-log { |&partial=$false &stream=both expected block|
  var capture-result = (command:capture-bytes &stream=$stream $block)

  defer $capture-result[clean]

  var log = ($capture-result[get-log])

  if $partial {
    if (not (str:contains $log $expected)) {
      -print-expected-and-actual [
        &expected-description='Expected partial log'
        &expected=$expected
        &actual-description='Actual log'
        &actual=$log
      ]

      fail 'expect-log (&partial) assertion failed'
    }
  } else {
    if (not-eq $log $expected) {
      -print-expected-and-actual [
        &expected-description='Expected log'
        &expected=$expected
        &actual-description='Actual log'
        &actual=$log
      ]

      fail 'expect-log assertion failed'
    }
  }
}
