use ./outcomes
use ./utils/map

var -stats-keys-by-outcome = [
  &$outcomes:passed=passed
  &$outcomes:failed=failed
]

fn -from-section { |section initial-counts|
  var counts = $initial-counts

  var test-results = $section[test-results]

  keys $test-results | each { |test-title|
    var test-result = $test-results[$test-title]

    var outcome = $test-result[outcome]

    set counts = (assoc $counts $outcome (+ $counts[$outcome] 1))
  }

  var sections = $section[sub-sections]

  keys $sections | each { |section-title|
    var section = $sections[$section-title]

    set counts = (-from-section $section $counts)
  }

  put $counts
}

fn from-section { |section|
  var counts = (
    -from-section $section [
      &$outcomes:passed=0
      &$outcomes:failed=0
    ] |
      map:filter-map (all) { |outcome value|
        var stats-key = $-stats-keys-by-outcome[$outcome]

        put [$stats-key $value]
      }
  )

  assoc $counts total (+ $counts[passed] $counts[failed])
}