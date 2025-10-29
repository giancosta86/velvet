use ./utils/diff
use ./utils/lang
use ./utils/string

fn -print-expected-and-actual { |inputs|
  var expected-description = $inputs[expected-description]
  var expected = $inputs[expected]
  var formatted-expected = (string:fancy $expected)

  var actual-description = $inputs[actual-description]
  var actual = $inputs[actual]
  var formatted-actual = (string:fancy $actual)

  echo (styled $expected-description':' red bold)
  echo $formatted-expected

  echo (styled $actual-description':' green bold)
  echo $formatted-actual

  echo 🔎 (styled DIFF: yellow bold)
  diff:diff $formatted-expected $formatted-actual | tail -n +3
  echo 🔎🔎🔎
}

fn -print-unexpected { |unexpected|
  echo (styled 'Unexpected:' red bold)
  echo (string:fancy $unexpected)
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
    var expected-minimal = (lang:minimize $expected)
    var actual-minimal = (lang:minimize $actual)

    if (not-eq $expected-minimal $actual-minimal) {
      -print-expected-and-actual [
        &expected-description='Expected'
        &expected=$expected-minimal
        &actual-description='Actual'
        &actual=$actual-minimal
      ]

      fail 'should-be assertion failed'
    }
  }
}

fn should-not-be { |&strict=$false unexpected|
  var actual = (one)

  if $strict {
    if (eq $unexpected $actual) {
      -print-unexpected $unexpected

      fail 'strict should-not-be assertion failed'
    }
  } else {
    var unexpected-minimal = (lang:minimize $unexpected)
    var actual-minimal = (lang:minimize $actual)

    if (eq $unexpected-minimal $actual-minimal) {
      -print-unexpected $unexpected-minimal

      fail 'should-not-be assertion failed'
    }
  }
}

fn fail-test {
  fail 'TEST SET TO FAIL'
}