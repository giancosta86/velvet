use github.com/giancosta86/aurora-elvish/map
use ./test-result

fn simplify { |describe-result|
  var simplified-test-results = (
    map:map $describe-result[test-results] { |key test-result|
      put [$key (test-result:simplify $test-result)]
    }
  )

  var simplified-sub-results = (
    map:map $describe-result[sub-results] { |key sub-result|
      put [$key (simplify $sub-result)]
    }
  )

  put [
    &test-results=$simplified-test-results
    &sub-results=$simplified-sub-results
  ]
}