use ./outcomes
use ./utils/map

fn -from-describe-result { |describe-result counts|
  var updated-counts = $counts

  var test-results = $describe-result[test-results]

  keys $test-results | each { |test-name|
    var test-result = $test-results[$test-name]
    var outcome = $test-result[outcome]

    set updated-counts = (assoc $updated-counts $outcome (+ $updated-counts[$outcome] 1))
  }

  var sub-results = $describe-result[sub-results]

  keys $sub-results | each { |sub-result-name|
    var sub-result = $sub-results[$sub-result-name]
    set updated-counts = (-from-describe-result $sub-result $updated-counts)
  }

  put $updated-counts
}

fn from-describe-result { |describe-result|
  var keys-by-outcome = [
    &$outcomes:passed=passed
    &$outcomes:failed=failed
  ]

  var counts = (
    -from-describe-result $describe-result [
      &$outcomes:passed=0
      &$outcomes:failed=0
    ] |
      map:filter-map (all) { |outcome value|
        var key = $keys-by-outcome[$outcome]
        put [$key $value]
      }
  )

  assoc $counts total (+ $counts[passed] $counts[failed])
}