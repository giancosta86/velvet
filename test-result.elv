use str
use ./outcomes
use ./utils/exception-lines

fn is { |artifact|
  has-key $artifact output
}

fn simplify { |test-result|
  dissoc $test-result exception-log
}

fn create-for-duplicated {
  var exception-log = (
    show ?(fail 'DUPLICATED TEST!') |
      exception-lines:trim-clockwork-stack |
      str:join "\n"
  )

  put [
    &output=''
    &outcome=$outcomes:failed
    &exception-log=$exception-log
  ]
}
