use str
use github.com/giancosta86/ethereal/v1/diff
use github.com/giancosta86/ethereal/v1/exception
use github.com/giancosta86/ethereal/v1/lang
use github.com/giancosta86/ethereal/v1/seq
use github.com/giancosta86/ethereal/v1/set
use github.com/giancosta86/ethereal/v1/string

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

var -should-be-error-message = 'should-be assertion failed'

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

var -should-not-be-error-message = 'should-not-be assertion failed'

fn should-not-be { |&strict=$false unexpected|
  var actual = (one)

  if $strict {
    if (eq $unexpected $actual) {
      -print-unexpected $unexpected

      fail 'strict '$-should-not-be-error-message
    }
  } else {
    var unexpected-minimal = (lang:flat-num $unexpected)
    var actual-minimal = (lang:flat-num $actual)

    if (eq $unexpected-minimal $actual-minimal) {
      -print-unexpected $unexpected-minimal

      fail $-should-not-be-error-message
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

var -should-not-emit-error-message = 'should-not-emit assertion failed'

fn should-not-emit { |&strict=$false unexpected-values|
  if (not-eq (kind-of $unexpected-values) list) {
    fail 'The argument must be a list of values'
  }

  var actual = (
    if $strict {
      put [(all)]
    } else {
      lang:flat-num [(all)]
    }
  )

  var unexpected-found = []

  all $unexpected-values | each { |raw-unexpected|
    var unexpected = (
      if $strict {
        put $raw-unexpected
      } else {
        lang:flat-num $raw-unexpected
      }
    )

    if (has-value $actual $unexpected) {
      set unexpected-found = [$@unexpected-found $unexpected]
    }
  }

  if (seq:is-non-empty $unexpected-found) {
    echo (styled 'Unexpected values found:' red bold)
    echo (string:pretty $unexpected-found)

    echo (styled 'Emitted values:' green bold)
    echo (string:pretty $actual)

    fail (
      if $strict {
        put 'strict '$-should-not-emit-error-message
      } else {
        put $-should-not-emit-error-message
      }
    )
  }
}

var -should-contain-error-message = 'should-contain assertion failed'

fn -fail-display-should-contain { |inputs|
  var source-description = $inputs[source-description]
  var source = $inputs[source]
  var missing-value-description = $inputs[missing-value-description]
  var missing-value = $inputs[missing-value]
  var error-message = $inputs[error-message]

  echo (styled $missing-value-description':' red bold)
  echo (string:pretty $missing-value)

  echo (styled $source-description':' green bold)
  echo (string:pretty $source)

  fail $error-message
}

var -should-contain-assertions = [
  &string={ |source-string sub-string error-message|
    if (not (str:contains $source-string $sub-string)) {
      -fail-display-should-contain [
        &source-description='Current string'
        &source=$source-string
        &missing-value-description='Missing sub-string'
        &missing-value=$sub-string
        &error-message=$error-message
      ]
    }
  }

  &list={ |source-list item error-message|
    if (not (has-value $source-list $item)) {
      -fail-display-should-contain [
        &source-description='Current list'
        &source=$source-list
        &missing-value-description='Missing item'
        &missing-value=$item
        &error-message=$error-message
      ]
    }
  }

  &map={ |source-map key error-message|
    if (not (has-key $source-map $key)) {
      -fail-display-should-contain [
        &source-description='Current map'
        &source=$source-map
        &missing-value-description='Missing key'
        &missing-value=$key
        &error-message=$error-message
      ]
    }
  }

  &ethereal-set={ |source-set item error-message|
    if (not (set:has-value $source-set $item)) {
      -fail-display-should-contain [
        &source-description='Current set'
        &source=(set:to-list $source-set)
        &missing-value-description='Missing item'
        &missing-value=$item
        &error-message=$error-message
      ]
    }
  }
]

fn -get-container-kind { |container|
  if (set:is-set $container) {
    put ethereal-set
  } else {
    kind-of $container
  }
}

fn should-contain { |&strict=$false value|
  var source = (one)

  var source-kind = (-get-container-kind $source)

  if (not (has-key $-should-contain-assertions $source-kind)) {
    fail 'Cannot assert should-contain - unexpected container kind: '$source-kind
  }

  var assertion = $-should-contain-assertions[$source-kind]

  var actual-source = (
    if $strict {
      put $source
    } else {
      lang:flat-num $source
    }
  )

  var actual-value = (
    if $strict {
      put $value
    } else {
      lang:flat-num $value
    }
  )

  var error-message = (
    if $strict {
      put 'strict '$-should-contain-error-message
    } else {
      put $-should-contain-error-message
    }
  )

  $assertion $actual-source $actual-value $error-message
}

fn fail-test {
  fail 'TEST SET TO FAIL'
}