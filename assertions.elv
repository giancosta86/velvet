use str
use github.com/giancosta86/ethereal/v1/diff
use github.com/giancosta86/ethereal/v1/exception
use github.com/giancosta86/ethereal/v1/lang
use github.com/giancosta86/ethereal/v1/string

var -should-be-error-message = 'should-be assertion failed'

fn throws { |block|
  try {
    $block | only-bytes >&2
  } catch e {
    put $e
  } else {
    fail 'The given code block did not fail!'
  }
}

fn -print-expected-and-actual { |inputs|
  var expected-description = $inputs[expected-description]
  var expected = $inputs[expected]
  var formatted-expected = (string:pretty $expected)

  var actual-description = $inputs[actual-description]
  var actual = $inputs[actual]
  var formatted-actual = (string:pretty $actual)

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
  echo (string:pretty $unexpected)
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

      fail 'strict '$-should-be-error-message
    }
  } else {
    var expected-minimal = (lang:flat-num $expected)
    var actual-minimal = (lang:flat-num $actual)

    if (not-eq $expected-minimal $actual-minimal) {
      -print-expected-and-actual [
        &expected-description='Expected'
        &expected=$expected-minimal
        &actual-description='Actual'
        &actual=$actual-minimal
      ]

      fail $-should-be-error-message
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
    var unexpected-minimal = (lang:flat-num $unexpected)
    var actual-minimal = (lang:flat-num $actual)

    if (eq $unexpected-minimal $actual-minimal) {
      -print-unexpected $unexpected-minimal

      fail 'should-not-be assertion failed'
    }
  }
}

fn should-emit { |&strict=$false &order-key=$nil expected|
  if (not-eq (kind-of $expected) list) {
    fail 'The expected argument must be a list of values'
  }

  var actual = (
    if $order-key {
      put [(
        all |
          order &key=$order-key
      )]
    } else {
      put [(all)]
    }
  )

  try {
    put $actual |
      should-be &strict=$strict $expected
  } catch e {
    var original-error-message = (exception:get-fail-content $e)

    if (str:has-suffix $original-error-message $-should-be-error-message) {
      str:replace should-be should-emit $original-error-message |
        fail (all)
    } else {
      fail $e
    }
  }
}

fn fail-test {
  fail 'TEST SET TO FAIL'
}