use str
use ./outcomes
use ./utils/command
use ./utils/exception

fn is { |artifact|
  has-key $artifact output
}

fn -get-exception-log-without-clockwork { |exception|
  show $exception |
    each { |line|
      if (
        str:trim-space $line |
          str:contains (all) '/velvet/utils/command.elv:11:9-14'
      ) {
        break
      }

      put $line
    } |
    str:join "\n"
}

fn from-capture-result { |capture-result|
  var outcome
  var exception-log

  if (
    or (eq $capture-result[status] $ok) (exception:is-return $capture-result[status])
  ) {
    set outcome = $outcomes:passed
    set exception-log = $nil
  } else {
    set outcome = $outcomes:failed
    set exception-log = (-get-exception-log-without-clockwork $capture-result[status])
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
  command:capture {
    fail 'DUPLICATED TEST!'
  } |
    from-capture-result (all)
}
