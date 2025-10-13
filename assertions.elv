use ./utils/diff
use ./utils/string

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
  var actual = (one)

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

fn should-not-be { |&strict=$false unexpected|
  var actual = (one)

  if $strict {
    if (eq $unexpected $actual) {
      print (styled 'Unexpected: ' red bold)
      pprint $actual

      fail 'strict should-not-be assertion failed'
    }
  } else {
    var unexpected-string = (string:get-minimal $unexpected)
    var actual-string = (string:get-minimal $actual)

    if (eq $unexpected-string $actual-string) {
      print (styled 'Unexpected: ' red bold)
      pprint $actual

      fail 'should-not-be assertion failed'
    }
  }
}

fn fail-test {
  fail 'TEST SET TO FAIL'
}