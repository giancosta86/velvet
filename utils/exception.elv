fn is-exception { |x|
  eq (kind-of $x) exception
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
    not (and (is-exception $potential-exception) (has-key $potential-exception reason))
  ) {
    put $false
    return
  }

  var reason = $potential-exception[reason]

  if (
    not (and (has-key $reason type) (has-key $reason name))
  ) {
    put $false
    return
  }

  and (eq $reason[type] flow) (eq $reason[name] return)
}