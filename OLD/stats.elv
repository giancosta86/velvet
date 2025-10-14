use ./outcomes
use ./utils/map

fn -from-describe-result { |describe-result initial-counts|
  var counts = $initial-counts

  var test-results = $describe-result[test-results]

  keys $test-results | each { |test-name|
    var test-result = $test-results[$test-name]

    var outcome = $test-result[outcome]

    set counts = (assoc $counts $outcome (+ $counts[$outcome] 1))
  }

  var sub-results = $describe-result[sub-results]

  keys $sub-results | each { |sub-result-name|
    var sub-result = $sub-results[$sub-result-name]

    set counts = (-from-describe-result $sub-result $counts)
  }

  put $counts
}

fn from-describe-result { |describe-result|
  var counts = (
    -from-describe-result $describe-result [
      &$outcomes:passed=0
      &$outcomes:failed=0
    ] |
      map:filter-map (all) { |outcome value|
        var output-keys-by-outcome = [
          &$outcomes:passed=passed
          &$outcomes:failed=failed
        ]

        var output-key = $output-keys-by-outcome[$outcome]

        put [$output-key $value]
      }
  )

  assoc $counts total (+ $counts[passed] $counts[failed])
}