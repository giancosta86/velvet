use ../../assertion
use ../../utils/output

fn should-be { |&strict=$false expected|
  var actual = (one | assertion:get-input &strict=$strict)

  set expected = (assertion:get-input &strict=$strict $expected)

  if (not-eq $expected $actual) {
    output:contrast [
      &red-description='Actual'
      &red=$actual
      &green-description='Expected'
      &green=$expected
      &show-diff=$true
    ]

    assertion:fail (src)
  }
}