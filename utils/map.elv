fn filter-map { |source mapper|
  var result-pairs = []

  keys $source |
    each { |key|
      var value = $source[$key]

      var new-pair = ($mapper $key $value)

      if (not-eq $new-pair $nil) {
        set result-pairs = [$@result-pairs $new-pair]
      }
    }

  make-map $result-pairs
}