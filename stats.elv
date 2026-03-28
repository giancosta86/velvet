use github.com/giancosta86/ethereal/v1/lang
use github.com/giancosta86/ethereal/v1/map
use github.com/giancosta86/ethereal/v1/operator
use ./outcomes
use ./section

var from-section~ = (
  var raw-empty = [
    &passed=0
    &failed=0
  ]

  fn raw-sum-two { |left right|
    put [
      &passed=(+ $left[passed] $right[passed])
      &failed=(+ $left[failed] $right[failed])
    ]
  }

  var raw-sum~ = (operator:multi-value $raw-empty $raw-sum-two~)

  var raw-from-test-results~
  var raw-from-sub-sections~

  fn raw-from-section { |section|
    var test-result-raw = (raw-from-test-results $section[test-results])

    var sub-sections-raw = (raw-from-sub-sections $section[sub-sections])

    raw-sum-two $test-result-raw $sub-sections-raw
  }

  set raw-from-test-results~ = { |test-results|
    var counts-by-outcome = [
      &$outcomes:passed=0
      &$outcomes:failed=0
    ]

    map:values $test-results | each { |test-result|
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

  set raw-from-sub-sections~ = { |sub-sections|
    map:values $sub-sections | each { |sub-section|
      raw-from-section $sub-section
    } |
      raw-sum
  }

  put { |@arguments|
    var section = (lang:get-single-input $arguments)

    var raw-stats = (raw-from-section $section)

    var total = (+ $raw-stats[passed] $raw-stats[failed])

    assoc $raw-stats total $total
  }
)

var empty = (from-section $section:empty)