use str
use ./outcomes
use ./utils/command
use ./utils/exception

fn -get-filtered-exception-log { |exception|
  show $exception |
    each { |line|
      if (
        str:trim-space $line |
          str:contains (all) 'github.com/giancosta86/velvet/utils/command.elv:'
      ) {
        break
      }

      put $line
    } |
    str:join "\n"
}

fn from-block { |block|
  var capture-result = (command:capture $block)

  var outcome
  var exception-log

  if (
    or (eq $capture-result[status] $ok) (exception:is-return $capture-result[status])
  ) {
    set outcome = $outcomes:passed
    set exception-log = $nil
  } else {
    set outcome = $outcomes:failed
    set exception-log = (-get-filtered-exception-log $capture-result[status])
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
