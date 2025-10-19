use ./outcomes

fn simplify { |test-result|
  dissoc $test-result exception-log
}

fn create-for-duplicate {
  var exception-log = 'DUPLICATE TEST!'

  put [
    &output=''
    &outcome=$outcomes:failed
    &exception-log=$exception-log
  ]
}
