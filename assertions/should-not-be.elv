use ./shared

var -error-message-base = 'should-not-be assertion failed'

fn should-not-be { |&strict=$false unexpected|
  var actual unexpected = (shared:get-minimals &strict=$strict $unexpected)

  if (eq $unexpected $actual) {
    shared:contrast [
      &red-description='Unexpected'
      &red=$unexpected
      &green-description='Actual'
      &green=$actual
      &show-diff=$false
    ]

    shared:fail-with-strict-prefix &strict=$strict $-error-message-base
  }
}