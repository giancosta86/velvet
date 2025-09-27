fn get-fail-message { |potential-exception|
  if (and (has-key $potential-exception reason) (has-key $potential-exception[reason] content)) {
    put $potential-exception[reason][content]
  } else {
    put $nil
  }
}