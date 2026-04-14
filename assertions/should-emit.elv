use ../assertion
use ./shared

fn should-emit { |&strict=$false &order-key=$nil &any-order=$false expected|
  if (not-eq (kind-of $expected) list) {
    fail 'The expected argument must be a list'
  }

  if $any-order {
    if $order-key {
      fail 'The &any-order flag and the &order-key option are mutually exclusive!'
    } else {
      set order-key = $to-string~
    }
  }

  var actual = [(
    shared:equalize &strict=$strict &order-key=$order-key
  )]

  var equalized-expected = [(
    all $expected |
      shared:equalize &strict=$strict &order-key=$order-key
  )]

  if (not-eq $actual $equalized-expected) {
    shared:contrast [
      &red-description='Expected values'
      &red=$equalized-expected
      &green-description='Emitted values'
      &green=$actual
      &show-diff=$true
    ]

    assertion:fail (src)
  }
}