use github.com/giancosta86/ethereal/v1/collection
use github.com/giancosta86/ethereal/v1/seq
use ../../assertion
use ../../output

fn should-contain-none { |&strict=$false unexpected-values|
  var collection = (one | assertion:get-input &strict=$strict)

  set unexpected-values = (assertion:get-input &strict=$strict $unexpected-values)

  var present-values = (
    collection:all $unexpected-values | seq:reduce [] { |cumulated-present unexpected-value|
      if (collection:contains $collection $unexpected-value) {
        conj $cumulated-present $unexpected-value
      } else {
        put $cumulated-present
      }
    }
  )

  if (collection:is-non-empty $present-values) {
    output:display-wrong 'Actual '(collection:detect-kind $collection) $collection

    output:display-wrong 'Unexpected '(collection:get-value-description $collection)'s' $present-values

    assertion:fail (src)
  }
}