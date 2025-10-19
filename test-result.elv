use ./outcomes

var duplicate = [
  &output=''
  &outcome=$outcomes:failed
  &exception-log='DUPLICATE TEST!'
]

fn simplify { |test-result|
  dissoc $test-result exception-log
}
