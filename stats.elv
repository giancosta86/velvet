fn create { |raw_values|
  put [
    &passed=$raw_values[passed]
    &failed=$raw_values[failed]
    &total=(+ $raw_values[passed] $raw_values[failed])
  ]
}

fn merge { |left right|
  create [
    &passed=(+ $left[passed] $right[passed])
    &failed=(+ $left[failed] $right[failed])
  ]
}