use ./test-result
use ./utils/map

fn simplify { |section|
  var simplified-test-results = (
    map:filter-map $section[test-results] { |test-title test-result|
      put [$test-title (test-result:simplify $test-result)]
    }
  )

  var simplified-sub-sections = (
    map:filter-map $section[sub-sections] { |sub-section-title sub-section|
      put [$sub-section-title (simplify $sub-section)]
    }
  )

  put [
    &test-results=$simplified-test-results
    &sub-sections=$simplified-sub-sections
  ]
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
        test-result:create-for-duplicated
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
    var actual-section = (
      if (has-key $left $sub-section-title)  {
        -merge-two $left[$sub-section-title] $right[$sub-section-title]
      } else {
        put $right[$sub-section-title]
      }
    )

    set sub-sections = (assoc $sub-sections $sub-section-title $actual-section)
  }

  put $sub-sections
}

fn merge {
  var result = [
    &test-results=[&]
    &sub-sections=[&]
  ]

  each { |section|
    set result = (-merge-two $result $section)
  }

  put $result
}