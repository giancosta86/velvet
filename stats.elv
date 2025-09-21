use ./outcomes

var -keys-by-outcome = [
  &$outcomes:passed=passed
  &$outcomes:failed=failed
]

fn -from-describe-result { |describe-result counts|
  var updated-counts = $counts

  var test-results = $describe-result[test-results]

  keys $test-results | each { |test-name|
    var test-result = $test-results[$test-name]
    var outcome = $test-result[outcome]

    var key = $-keys-by-outcome[$outcome]

    set updated-counts = (assoc $updated-counts $key (+ $updated-counts[$key] 1))
  }

  var sub-results = $describe-result[sub-results]

  keys $sub-results | each { |sub-result-name|
    var sub-result = $sub-results[$sub-result-name]
    set updated-counts = (-from-describe-result $sub-result $updated-counts)
  }

  put $updated-counts
}

fn from-describe-result { |describe-result|
  var partial-result = (-from-describe-result $describe-result [
    &passed=0
    &failed=0
  ])

  assoc $partial-result total (+ $partial-result[passed] $partial-result[failed])
}