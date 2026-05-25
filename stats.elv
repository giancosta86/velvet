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

  set raw-from-test-results~ = { |test-results|
    var total-passed = 0
    var total-failed = 0

    map:values $test-results | each { |test-result|
      var outcome = $test-result[outcome]

      if (eq $outcome $outcomes:passed) {
        set total-passed = (+ $total-passed 1)
      } elif (eq $outcome $outcomes:failed) {
        set total-failed = (+ $total-failed 1)
      } else {
        fail 'Uknown outcome: '$outcome
      }
    }

    put [
      &passed=$total-passed
      &failed=$total-failed
    ]
  }

  fn raw-from-section { |section|
    var test-result-raw = (raw-from-test-results $section[test-results])

    var sub-sections-raw = (raw-from-sub-sections $section[sub-sections])

    raw-sum-two $test-result-raw $sub-sections-raw
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