use ./shared

var -error-message-base = 'should-emit assertion failed'

fn should-emit { |&strict=$false &order-key=$nil expected|
  if (not-eq (kind-of $expected) list) {
    fail 'The expected argument must be a list of values'
  }

  var actual = (
    if $order-key {
      put [(
        all |
          order &key=$order-key
      )]
    } else {
      put [(all)]
    } |
      shared:get-minimal &strict=$strict
  )

  var expected = (shared:get-minimal &strict=$strict $expected)

  if (not-eq $actual $expected) {
    shared:contrast [
      &red-description='Expected'
      &red=$expected
      &green-description='Actual'
      &green=&actual
      &show-diff=$true
    ]

    shared:fail-with-strict-prefix &strict=$strict $-error-message-base
  }
}