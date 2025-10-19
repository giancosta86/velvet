use ./outcomes
use ./utils/map

var -raw-empty = [
  &passed=0
  &failed=0
]

fn -raw-sum-two { |left right|
  put [
    &passed=(+ $left[passed] $right[passed])
    &failed=(+ $left[failed] $right[failed])
  ]
}

fn -raw-sum {
  var result = $-raw-empty

  each { |current-stats|
    set result = (-raw-sum-two $result $current-stats)
  }

  put $result
}

var -raw-from-test-results~
var -raw-from-sub-sections~

fn -raw-from-section { |section|
  var test-result-counts = (-raw-from-test-results $section[test-results])

  var sub-sections-counts = (-raw-from-sub-sections $section[sub-sections])

  -raw-sum-two $test-result-counts $sub-sections-counts
}

set -raw-from-test-results~ = { |test-results|
  var counts-by-outcome = [
    &$outcomes:passed=0
    &$outcomes:failed=0
  ]

  keys $test-results | each { |test-title|
    var test-result = $test-results[$test-title]

    var outcome = $test-result[outcome]

    var updated-outcome-count = (+ $counts-by-outcome[$outcome] 1)

    set counts-by-outcome = (
      assoc $counts-by-outcome $outcome $updated-outcome-count
    )
  }

  put [
    &passed=$counts-by-outcome[$outcomes:passed]
    &failed=$counts-by-outcome[$outcomes:failed]
  ]
}

set -raw-from-sub-sections~ = { |sub-sections|
  keys $sub-sections | each { |sub-title|
    var sub-section = $sub-sections[$sub-title]

    -raw-from-section $sub-section
  } |
    -raw-sum
}

fn from-section { |section|
  var raw-counts = (-raw-from-section $section)

  assoc $raw-counts total (+ $raw-counts[passed] $raw-counts[failed])
}