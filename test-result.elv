use github.com/giancosta86/ethereal/v1/lang
use ./outcomes

fn success { |output-lines|
  put [
    &outcome=$outcomes:passed
    &output-lines=$output-lines
    &exception-lines=$nil
  ]
}

fn failure { |output-lines exception-lines|
  put [
    &outcome=$outcomes:failed
    &output-lines=$output-lines
    &exception-lines=$exception-lines
  ]
}

var duplicate-test = (failure [] ?(fail 'DUPLICATE TEST'))