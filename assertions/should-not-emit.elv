use github.com/giancosta86/ethereal/v1/seq
use github.com/giancosta86/ethereal/v1/set
use ../assertion
use ../utils/output

fn should-not-emit { |&strict=$false unexpected|
  if (not-eq (kind-of $unexpected) list) {
    fail 'The unexpected argument must be a list'
  }

  var actual = (
    each { |value| assertion:get-input &strict=$strict $value } |
      set:of
  )

  var unexpected-found = (
    assertion:get-input &strict=$strict $unexpected |
      all (all) |
      seq:reduce [] { |cumulated-found current-unexpected|
        if (set:has-value $actual $current-unexpected) {
          conj $cumulated-found $current-unexpected
        } else {
          put $cumulated-found
        }
      }
  )

  if (seq:is-non-empty $unexpected-found) {
    output:display-wrong 'Unexpected values' $unexpected-found

    assertion:fail (src)
  }
}