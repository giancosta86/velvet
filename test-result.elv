use github.com/giancosta86/aurora-elvish/command
use ./outcomes

fn from-block { |block|
  var capture-result = (command:capture $block)

  var outcome
  var exception-log

  if (eq $capture-result[status] $ok) {
    set outcome = $outcomes:passed
    set exception-log = $nil
  } else {
    set outcome = $outcomes:failed
    set exception-log = (show $capture-result[status] | slurp)
  }

  put [
    &output=$capture-result[output]
    &outcome=$outcome
    &exception-log=$exception-log
  ]
}

fn simplify { |test-result|
  dissoc $test-result exception-log
}

fn create-for-duplicated {
  from-block {
    fail 'DUPLICATED TEST!'
  }
}
