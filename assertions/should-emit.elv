use ./shared

var -error-message-base = 'should-emit assertion failed'

fn should-emit { |&strict=$false &order-key=$nil &any-order=$false expected|
  if (not-eq (kind-of $expected) list) {
    fail 'The expected argument must be a list of values'
  }

  if $any-order {
    if $order-key {
      fail 'The &any-order flag and the &order-key option are mutually exclusive!'
    } else {
      set order-key = $to-string~
    }
  }

  var actual = [(
    all |
      shared:equalize &strict=$strict &order-key=$order-key
  )]

  var expected = [(
    all $expected |
      shared:equalize &strict=$strict &order-key=$order-key
  )]

  if (not-eq $actual $expected) {
    shared:contrast [
      &red-description='Expected values'
      &red=$expected
      &green-description='Emitted values'
      &green=$actual
      &show-diff=$true
    ]

    shared:fail-with-strict-prefix &strict=$strict $-error-message-base
  }
}