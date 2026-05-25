use str
use github.com/giancosta86/ethereal/v1/seq
use github.com/giancosta86/ethereal/v1/string
use ../../outcomes
use ../../summary

var report~ = (
  var sorting-algorithm = $str:to-lower~

  var styles-by-outcome = [
    &$outcomes:passed=[
      &emoji=✅
      &color=green
    ]

    &$outcomes:failed=[
      &emoji=❌
      &color=red
    ]
  ]

  fn get-indentation { |level|
    str:repeat ' ' (* $level 4)
  }

  fn display-wrong-lines { |description wrong-lines|
    if (seq:is-non-empty $wrong-lines) {
      echo (styled $description red bold)
      echo

      all $wrong-lines |
        each $echo~

      echo
    }
  }

  fn display-test-result { |test-title test-result level|
    var outcome = $test-result[outcome]

    var style = $styles-by-outcome[$outcome]

    echo (get-indentation $level)''$style[emoji] (styled $test-title $style[color] bold)

    if (eq $outcome $outcomes:failed) {
      {
        display-wrong-lines '*** OUTPUT LOG (stdout + stderr) ***' $test-result[output-lines]

        display-wrong-lines '*** EXCEPTION LOG ***' $test-result[exception-lines]
      } |
        string:prefix-lines (get-indentation (+ $level 1))
    }
  }

  fn display-section { |section level|
    keys $section[test-results] |
      order &key=$sorting-algorithm |
      each { |test-title|
        var test-result = $section[test-results][$test-title]

        display-test-result $test-title $test-result $level
      }

    var section-has-test-results = (seq:is-non-empty $section[test-results])

    var before-first-sub-section = $true

    keys $section[sub-sections] |
      order &key=$sorting-algorithm |
      each { |sub-title|
        if $before-first-sub-section {
          set before-first-sub-section = $false

          if $section-has-test-results  {
            echo
          }
        } else {
          echo
        }

        echo (get-indentation $level)''(styled $sub-title white bold)

        var sub-section = $section[sub-sections][$sub-title]

        display-section $sub-section (+ $level 1)
      }

    if (and (== $level 0) (not $before-first-sub-section)) {
      echo
    }
  }

  fn display-stats { |stats|
    var total-style = (
      if (== 0 $stats[failed]) {
        put $styles-by-outcome[$outcomes:passed]
      } else {
        put $styles-by-outcome[$outcomes:failed]
      }
    )

    var total-fragment = (
      put 'Total tests: '$stats[total]'.' |
        styled (all) bold $total-style[color] |
        put $total-style[emoji]' '(all)
    )

    var fragments = [$total-fragment]

    if (> $stats[failed] 0) {
      var passed-fragment = (styled 'Passed: '$stats[passed]'.' green bold)
      var failed-fragment = (styled 'Failed: '$stats[failed]'.' red bold)

      set fragments = (conj $fragments $passed-fragment $failed-fragment)
    }

    echo $@fragments
  }

  fn display-crashed-scripts { |exception-lines-by-script|
    if (seq:is-empty $exception-lines-by-script) {
      return
    }

    echo
    echo
    echo ⛔⛔⛔ (styled 'CRASHED SCRIPTS' bold red) ⛔⛔⛔

    keys $exception-lines-by-script |
      order &key=$sorting-algorithm |
      each { |crashed-script-path|
        var exception-lines = $exception-lines-by-script[$crashed-script-path]

        echo
        echo ⛔ (styled $crashed-script-path bold red)
        echo

        all $exception-lines |
          each $echo~

        echo
        echo
      }
  }

  put { |summary|
    if (eq $summary $summary:empty) {
      echo 💬 (styled 'No test structure found.' bold white)
      return
    }

    display-section $summary[section] 0

    display-stats $summary[stats]

    display-crashed-scripts $summary[exception-lines-by-script]
  }
)