fn get-fail-message { |potential-fail|
  if (and (has-key $potential-fail reason) (has-key $potential-fail[reason] content)) {
    put $potential-fail[reason][content]
  } else {
    put $nil
  }
}