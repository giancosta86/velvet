use ./shared

var -error-message-base = 'should-be assertion failed'

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

    shared:fail-with-strict-prefix &strict=$strict $-error-message-base
  }
}