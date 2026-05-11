use github.com/giancosta86/ethereal/v1/collection
use github.com/giancosta86/ethereal/v1/seq
use ../../assertion
use ../../utils/output

fn should-contain-all { |&strict=$false expected-values|
  var collection = (one | assertion:get-input &strict=$strict)

  set expected-values = (assertion:get-input &strict=$strict $expected-values)

  var missing-values = (
    collection:all $expected-values | seq:reduce [] { |cumulated-missing expected-value|
      if (collection:contains $collection $expected-value) {
        put $cumulated-missing
      } else {
        conj $cumulated-missing $expected-value
      }
    }
  )

  if (collection:is-non-empty $missing-values) {
    output:display-wrong 'Actual '(collection:detect-kind $collection) $collection

    output:display-wrong 'Missing '(collection:get-value-description $collection)'s' $missing-values

    assertion:fail (src)
  }
}