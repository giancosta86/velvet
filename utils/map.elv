fn map { |source mapper|
  keys $source |
    each { |key|
      var value = $source[$key]
      $mapper $key $value
    } |
    make-map
}