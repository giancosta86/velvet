use str
use ../outcomes

fn -print-indentation { |level|
  print (str:repeat ' ' (* $level 4))
}

fn -print-test-result { |test-title test-result level|
  var outcome = $test-result[outcome]

  var color
  var emoji

  if (eq $outcome $outcomes:passed) {
    set color = green
    set emoji = ✅
  } elif (eq $outcome $outcomes:failed) {
    set color = red
    set emoji = ❌
  } else {
    fail 'Unknown outcome'
  }

  -print-indentation $level
  echo (styled $test-title $color bold) $emoji

  if (eq $outcome $outcomes:failed) {
    echo $test-result[output]

    if $test-result[exception-log] {
      echo $test-result[exception-log]
    }
  }
}

fn -display-describe-result { |describe-result level|
  keys $describe-result[test-results] |
    order &key=$str:to-lower~ |
    each { |test-name|
      var test-result = $describe-result[test-results][$test-name]

      -print-test-result $test-name $test-result $level
    }

  keys $describe-result[sub-results] |
    order &key=$str:to-lower~ |
    each { |sub-result-name|
      -print-indentation $level
      echo $sub-result-name

      var sub-result = $describe-result[sub-results][$sub-result-name]

      -display-describe-result $sub-result (+ $level 1)
    }
}

fn display { |describe-result stats|
  var items-count = (+ (count $describe-result[test-results]) (count $describe-result[sub-results]))

  if (== $items-count 0) {
    echo 💬 No test structure found.
    return
  }

  -display-describe-result $describe-result 0

  echo (styled 'Total tests: '$stats[total]'.' bold) (styled 'Passed: '$stats[passed]'.' green bold) (styled 'Failed: '$stats[failed]'.' red bold)
}