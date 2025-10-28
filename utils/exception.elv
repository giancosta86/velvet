fn is-exception { |x|
  kind-of $x |
    eq (all) exception
}

fn -get-potential-exception { |@arguments|
  var result-retriever = [
    &(num 0)={ one }
    &(num 1)={ put $arguments[0] }
  ][(count $arguments)]

  $result-retriever
}

fn get-reason { |@arguments|
  var potential-exception = (-get-potential-exception $@arguments)

  if (
    and (is-exception $potential-exception) (has-key $potential-exception reason)
  ) {
    put $potential-exception[reason]
  } else {
    put $nil
  }
}

fn get-fail-message { |@arguments|
  var reason = (get-reason $@arguments)

  if (
    and $reason (has-key $reason content)
  ) {
    put $reason[content]
  } else {
    put $nil
  }
}

fn is-return { |potential-exception|
  var reason = (get-reason $potential-exception)

  if (
    and $reason (has-key $reason type) (has-key $reason name) |
      not (all)
  ) {
    put $false
    return
  }

  and (eq $reason[type] flow) (eq $reason[name] return)
}

fn expect-throws { |block|
  try {
    $block | only-bytes >&2
  } catch e {
    put $e
  } else {
    fail 'The given code block did not fail!'
  }
}