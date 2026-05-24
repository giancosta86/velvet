use github.com/giancosta86/ethereal/v1/collection
use ../../assertion
use ../../output

fn should-not-contain { |&strict=$false unexpected-value|
  var collection = (one | assertion:get-input &strict=$strict)

  set unexpected-value = (assertion:get-input &strict=$strict $unexpected-value)

  if (collection:contains $collection $unexpected-value) {
    output:display-wrong 'Actual '(collection:detect-kind $collection) $collection

    output:display-wrong 'Unexpected '(collection:get-value-description $collection) $unexpected-value

    assertion:fail (src)
  }
}