fn is-exception { |x|
  kind-of $x |
    eq (all) exception
}

fn get-fail-message { |potential-exception|
  if (
    and (is-exception $potential-exception) (has-key $potential-exception reason) (has-key $potential-exception[reason] content)
  ) {
    put $potential-exception[reason][content]
  } else {
    put $nil
  }
}

fn is-return { |potential-exception|
  if (
    and (is-exception $potential-exception) (has-key $potential-exception reason) |
      not (all)
  ) {
    put $false
    return
  }

  var reason = $potential-exception[reason]

  if (
    and (has-key $reason type) (has-key $reason name) |
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