use github.com/giancosta86/ethereal/v1/lang
use ./outcomes

fn success { |output-lines|
  put [
    &outcome=$outcomes:passed
    &output-lines=$output-lines
    &exception=$nil
  ]
}

fn failure { |output-lines exception|
  put [
    &outcome=$outcomes:failed
    &output-lines=$output-lines
    &exception=$exception
  ]
}

var duplicate-test = (failure [] ?(fail 'DUPLICATE TEST'))

fn simplify { |@arguments|
  var test-result = (lang:get-single-input $arguments)

  dissoc $test-result exception
}
