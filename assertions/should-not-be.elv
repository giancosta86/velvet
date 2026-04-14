use ../assertion
use ./shared

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

    assertion:fail (src)
  }
}