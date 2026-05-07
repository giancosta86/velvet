use github.com/giancosta86/ethereal/v1/seq
use ../assertion
use ../utils/output

fn should-not-emit { |&strict=$false unexpected|
  if (not-eq (kind-of $unexpected) list) {
    fail 'The unexpected argument must be a list'
  }

  var actual = [(
    each { |value| assertion:get-input &strict=$strict $value }
  )]

  var unexpected-found = []

  all $unexpected | each { |raw-unexpected|
    var current-unexpected = (
      assertion:get-input &strict=$strict $raw-unexpected
    )

    if (has-value $actual $current-unexpected) {
      set unexpected-found = (conj $unexpected-found $current-unexpected)
    }
  }

  if (seq:is-non-empty $unexpected-found) {
    output:highlight-wrong 'Unexpected values' $unexpected-found

    assertion:fail (src)
  }
}