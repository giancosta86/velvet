use github.com/giancosta86/ethereal/v1/seq
use ./shared

var -error-message-base = 'should-not-emit assertion failed'

fn should-not-emit { |&strict=$false unexpected-values|
  if (not-eq (kind-of $unexpected-values) list) {
    fail 'The argument must be a list of values'
  }

  var actual = (
    put [(all)] |
      shared:get-minimal &strict=$strict
  )

  var unexpected-found = []

  all $unexpected-values | each { |raw-unexpected|
    var unexpected = (shared:get-minimal &strict=$strict $raw-unexpected)

    if (has-value $actual $unexpected) {
      set unexpected-found = (conj $unexpected-found $unexpected)
    }
  }

  if (seq:is-non-empty $unexpected-found) {
    shared:contrast [
      &red-description='Unexpected values found'
      &red=$unexpected-found
      &green-description='Emitted values'
      &green=$actual
      &show-diff=$false
    ]

    shared:fail-with-strict-prefix &strict=$strict $-error-message-base
  }
}