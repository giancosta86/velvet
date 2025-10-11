use str
use ../outcomes
use ../utils/string

var -styles-by-outcome = [
  &$outcomes:passed=[
    &emoji=✅
    &color=green
  ]

  &$outcomes:failed=[
    &emoji=❌
    &color=red
  ]
]

fn -get-indentation { |level|
  str:repeat ' ' (* $level 4)
}

fn -display-test-result { |test-title test-result level|
  var outcome = $test-result[outcome]

  var style = $-styles-by-outcome[$outcome]

  var indentation = (-get-indentation $level)

  echo $indentation''(styled $test-title $style[color] bold) $style[emoji]

  if (eq $outcome $outcomes:failed) {
    var logging-indentation = (-get-indentation (+ $level 1))

    {
      if (not-eq $test-result[output] '') {
        echo (styled '*** OUTPUT LOG (stdout + stderr) ***' red bold)
        echo
        echo (str:trim-space $test-result[output])
        echo
      }

      echo (styled '*** EXCEPTION LOG ***' red bold)
      echo
      echo (str:trim-space $test-result[exception-log])
      echo
    } |
      string:indent-lines $logging-indentation |
      echo (all)
  }
}

fn -display-describe-result { |describe-result level|
  keys $describe-result[test-results] |
    order &key=$str:to-lower~ |
    each { |test-name|
      var test-result = $describe-result[test-results][$test-name]

      -display-test-result $test-name $test-result $level
    }

  var is-first-sub-result = $true

  keys $describe-result[sub-results] |
    order &key=$str:to-lower~ |
    each { |sub-result-name|
      if $is-first-sub-result {
        set is-first-sub-result = $false

        var preceding-test-results = (count $describe-result[test-results])

        if (> $preceding-test-results 0)  {
          echo
        }
      } else {
        echo
      }

      var indentation = (-get-indentation $level)

      echo $indentation''(styled $sub-result-name white bold)

      var sub-result = $describe-result[sub-results][$sub-result-name]

      -display-describe-result $sub-result (+ $level 1)
    }
}

fn -display-stats { |stats|
  var total-style

  if (== 0 $stats[failed]) {
    set total-style = $-styles-by-outcome[$outcomes:passed]
  } else {
    set total-style = $-styles-by-outcome[$outcomes:failed]
  }

  var total-fragment = $total-style[emoji]' '(styled 'Total tests: '$stats[total]'.' bold $total-style[color])

  var fragments = [$total-fragment]

  if (> $stats[failed] 0) {
    var passed-fragment = (styled 'Passed: '$stats[passed]'.' green bold)
    var failed-fragment = (styled 'Failed: '$stats[failed]'.' red bold)

    set fragments = [$@fragments $passed-fragment $failed-fragment]
  }

  echo $@fragments
}

fn display { |describe-result stats|
  var items-count = (+ (count $describe-result[test-results]) (count $describe-result[sub-results]))

  if (== $items-count 0) {
    echo 💬 (styled 'No test structure found.' bold white)
    return
  }

  -display-describe-result $describe-result 0

  echo

  -display-stats $stats
}