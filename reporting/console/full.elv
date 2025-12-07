use str
use github.com/giancosta86/ethereal/v1/string
use ../../outcomes

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

  echo $indentation''$style[emoji] (styled $test-title $style[color] bold)

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
      string:prefix-lines $logging-indentation |
      slurp |
      put (all)[..-1] |
      echo (all)
  }
}

fn -display-section { |section level|
  keys $section[test-results] |
    order &key=$str:to-lower~ |
    each { |test-title|
      var test-result = $section[test-results][$test-title]

      -display-test-result $test-title $test-result $level
    }

  var is-first-sub-section = $true

  keys $section[sub-sections] |
    order &key=$str:to-lower~ |
    each { |sub-title|
      if $is-first-sub-section {
        set is-first-sub-section = $false

        var preceding-test-results = (count $section[test-results])

        if (> $preceding-test-results 0)  {
          echo
        }
      } else {
        echo
      }

      var indentation = (-get-indentation $level)

      echo $indentation''(styled $sub-title white bold)

      var sub-section = $section[sub-sections][$sub-title]

      -display-section $sub-section (+ $level 1)
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

fn report { |summary|
  var section = $summary[section]

  var items-count = (+ (count $section[test-results]) (count $section[sub-sections]))

  if (== $items-count 0) {
    echo 💬 (styled 'No test structure found.' bold white)
    return
  }

  -display-section $section 0

  echo

  -display-stats $summary[stats]
}