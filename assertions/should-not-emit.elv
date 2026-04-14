use github.com/giancosta86/ethereal/v1/seq
use ../assertion
use ./shared

fn should-not-emit { |&strict=$false unexpected|
  if (not-eq (kind-of $unexpected) list) {
    fail 'The unexpected argument must be a list'
  }

  var actual = (
    put [(all)] |
      shared:get-minimal &strict=$strict
  )

  var unexpected-found = []

  all $unexpected | each { |raw-unexpected|
    var current-unexpected = (
      shared:get-minimal &strict=$strict $raw-unexpected
    )

    if (has-value $actual $current-unexpected) {
      set unexpected-found = (conj $unexpected-found $current-unexpected)
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

    assertion:fail (src)
  }
}