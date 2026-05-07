use github.com/giancosta86/ethereal/v1/collection
use ../../assertion
use ../../utils/output

fn should-contain { |&strict=$false expected-value|
  var collection = (one | assertion:get-input &strict=$strict)

  set expected-value = (assertion:get-input &strict=$strict $expected-value)

  if (not (collection:contains $collection $expected-value)) {
    output:contrast [
      &red-description='Actual '(collection:detect-kind $collection)
      &red=$collection
      &green-description='Expected '(collection:get-value-description $collection)
      &green=$expected-value
      &show-diff=$false
    ]

    assertion:fail (src)
  }
}