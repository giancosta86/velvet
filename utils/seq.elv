fn split-by-chunk-count { |chunk-count|
  if (<= $chunk-count 0) {
    fail 'The chunk count must be > 0! Requested: '$chunk-count
  }

  var chunks = [(repeat $chunk-count [])]

  var chunk-index = 0

  each { |item|
    var current-chunk = $chunks[$chunk-index]

    var updated-chunk = [$@current-chunk $item]

    set chunks = (assoc $chunks $chunk-index $updated-chunk)

    set chunk-index = (
      + $chunk-index 1 |
        % (all) $chunk-count
    )
  }

  all $chunks |
    keep-if { |chunk| not-eq $chunk [] }
}