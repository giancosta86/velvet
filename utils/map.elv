fn get-value { |&default=$nil source key|
  if (has-key $source $key) {
    put $source[$key]
  } else {
    put $default
  }
}

fn map { |source mapper|
  keys $source |
    each { |key|
      var value = $source[$key]
      $mapper $key $value
    } |
    make-map
}