use str
use ./utils/diff
use ./utils/string

fn expect-crash { |block|
  try {
    $block | only-bytes >&2
  } catch e {
    put $e
  } else {
    fail 'The given code block did not fail!'
  }
}

fn -print-expected-and-actual { |inputs|
  var actual-description = $inputs[actual-description]
  var actual = $inputs[actual]
  var formatted-actual = (pprint $actual | slurp)

  var expected-description = $inputs[expected-description]
  var expected = $inputs[expected]
  var formatted-expected = (pprint $expected | slurp)

  print (styled $actual-description': ' red bold)
  echo $formatted-actual

  print (styled $expected-description': ' green bold)
  echo $formatted-expected

  echo 🔎 (styled DIFF: yellow bold)
  diff:diff $formatted-actual $formatted-expected | tail -n +3
  echo 🔎🔎🔎
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

fn fail-test {
  fail 'TEST SET TO FAIL'
}