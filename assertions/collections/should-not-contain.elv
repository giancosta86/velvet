use github.com/giancosta86/ethereal/v1/collection
use ../../assertion
use ../../utils/output

fn should-not-contain { |&strict=$false unexpected-value|
  var collection = (one | assertion:get-input &strict=$strict)

  set unexpected-value = (assertion:get-input &strict=$strict $unexpected-value)

  if (collection:contains $collection $unexpected-value) {
    output:contrast [
      &red-description='Actual '(collection:detect-kind $collection)
      &red=$collection
      &green-description='Unexpected '(collection:get-value-description $collection)
      &green=$unexpected-value
      &show-diff=$false
    ]

    assertion:fail (src)
  }
}