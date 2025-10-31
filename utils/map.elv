fn filter-map { |source mapper|
  keys $source |
    each { |key|
      var value = $source[$key]

      var new-pair = ($mapper $key $value)

      if (not-eq $new-pair $nil) {
        put $new-pair
      }
    } |
    make-map
}