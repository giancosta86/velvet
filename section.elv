use ./test-result
use ./utils/map

var empty = [
  &test-results=[&]
  &sub-sections=[&]
]

fn is-section { |artifact|
  has-key $artifact sub-sections
}

fn map-test-results-in-tree { |root-section test-result-mapper|
  var updated-test-results-in-root = (
    map:filter-map $root-section[test-results] { |test-title test-result|
      put [$test-title ($test-result-mapper $test-result)]
    }
  )

  var updated-sub-sections = (
    map:filter-map $root-section[sub-sections] { |section-title sub-section|
      put [$section-title (map-test-results-in-tree $sub-section $test-result-mapper)]
    }
  )

  put [
    &test-results=$updated-test-results-in-root
    &sub-sections=$updated-sub-sections
  ]
}

fn simplify { |section|
  map-test-results-in-tree $section $test-result:simplify~
}

var -merge-test-results~
var -merge-sub-sections~

fn -merge-two { |left right|
  put [
    &test-results=(
      -merge-test-results $left[test-results] $right[test-results]
    )

    &sub-sections=(
      -merge-sub-sections $left[sub-sections] $right[sub-sections]
    )
  ]
}

set -merge-test-results~ = { |left right|
  var test-results = $left

  keys $right | each { |test-title|
    var actual-test-result = (
      if (has-key $left $test-title)  {
        test-result:create-for-duplicate
      } else {
        put $right[$test-title]
      }
    )

    set test-results = (assoc $test-results $test-title $actual-test-result)
  }

  put $test-results
}

set -merge-sub-sections~ = { |left right|
  var sub-sections = $left

  keys $right | each { |sub-section-title|
    var actual-sub-section = (
      if (has-key $left $sub-section-title)  {
        -merge-two $left[$sub-section-title] $right[$sub-section-title]
      } else {
        put $right[$sub-section-title]
      }
    )

    set sub-sections = (assoc $sub-sections $sub-section-title $actual-sub-section)
  }

  put $sub-sections
}

fn merge {
  var result = $empty

  each { |section|
    set result = (-merge-two $result $section)
  }

  put $result
}