use ../../assertion
use ../../output

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

  var sorting-block = (
    if $order-key {
      put { order &key=$order-key }
    } else {
      put $all~
    }
  )

  var list-processor = {
    each { |value| assertion:get-input &strict=$strict $value } |
      $sorting-block
  }

  var actual = [($list-processor)]

  var expected = [(
    all $expected |
      $list-processor
  )]

  if (not-eq $actual $expected) {
    output:contrast [
      &red-description='Emitted values'
      &red=$actual
      &green-description='Expected values'
      &green=$expected
      &show-diff=$true
    ]

    assertion:fail (src)
  }
}