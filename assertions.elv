use str
use ./utils/console
use ./utils/diff
use ./utils/string

fn assert { |predicate|
  if (not $predicate) {
    fail 'Assertion failed!'
  }
}

fn expect-crash { |block|
  try {
    $block | only-bytes
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
  var actual-description = $inputs[actual-description]
  var actual = $inputs[actual]
  var formatted-actual = (pprint $actual | slurp)

  var expected-description = $inputs[expected-description]
  var expected = $inputs[expected]
  var formatted-expected = (pprint $expected | slurp)

  #TODO: why are these >&2 still needed?
  print (styled $actual-description': ' red bold) >&2
  echo $formatted-actual >&2

  print (styled $expected-description': ' green bold) >&2
  echo $formatted-expected >&2

  console:show-block (styled DIFF: yellow bold) {
    diff:diff $formatted-actual $formatted-expected | tail -n +3 >&2
  }
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
