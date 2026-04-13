use ../assertion
use ./shared

fn should-be { |&strict=$false expected|
  var actual expected = (shared:get-minimals &strict=$strict $expected)

  if (not-eq $expected $actual) {
    shared:contrast [
      &red-description='Expected'
      &red=$expected
      &green-description='Actual'
      &green=$actual
      &show-diff=$true
    ]

    assertion:fail (src)
  }
}