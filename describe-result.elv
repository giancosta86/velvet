use ./test-result
use ./utils/map

fn simplify { |describe-result|
  var simplified-test-results = (
    map:filter-map $describe-result[test-results] { |test-name test-result|
      put [$test-name (test-result:simplify $test-result)]
    }
  )

  var simplified-sub-results = (
    map:filter-map $describe-result[sub-results] { |sub-result-name sub-result|
      put [$sub-result-name (simplify $sub-result)]
    }
  )

  put [
    &test-results=$simplified-test-results
    &sub-results=$simplified-sub-results
  ]
}

var -merge-test-results~
var -merge-sub-results~

fn merge { |left right|
  put [
    &test-results=(
      -merge-test-results $left[test-results] $right[test-results]
    )

    &sub-results=(
      -merge-sub-results $left[sub-results] $right[sub-results]
    )
  ]
}

set -merge-test-results~ = { |left right|
  var test-results = $left

  keys $right | each { |test-name|
    var actual-test-result = (
      if (has-key $left $test-name)  {
        test-result:create-for-duplicated
      } else {
        put $right[$test-name]
      }
    )

    set test-results = (assoc $test-results $test-name $actual-test-result)
  }

  put $test-results
}

set -merge-sub-results~ = { |left right|
  var sub-results = $left

  keys $right | each { |sub-result-name|
    var actual-sub-result = (
      if (has-key $left $sub-result-name)  {
        merge $left[$sub-result-name] $right[$sub-result-name]
      } else {
        put $right[$sub-result-name]
      }
    )

    set sub-results = (assoc $sub-results $sub-result-name $actual-sub-result)
  }

  put $sub-results
}