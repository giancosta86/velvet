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

  fn display-test-result { |test-title test-result level|
    var outcome = $test-result[outcome]

    var style = $styles-by-outcome[$outcome]

    echo (get-indentation $level)''$style[emoji] (styled $test-title $style[color] bold)

    if (eq $outcome $outcomes:failed) {
      {
        if (seq:is-non-empty $test-result[output-lines]) {
          echo (styled '*** OUTPUT LOG (stdout + stderr) ***' red bold)
          echo

          all $test-result[output-lines] |
            each $echo~

          echo
        }

        if (seq:is-non-empty $test-result[exception-lines]) {
          echo (styled '*** EXCEPTION LOG ***' red bold)
          echo

          all $test-result[exception-lines] |
            each $echo~

          echo
        }
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

    var is-first-sub-section = $true

    keys $section[sub-sections] |
      order &key=$sorting-algorithm |
      each { |sub-title|
        if $is-first-sub-section {
          set is-first-sub-section = $false

          if (seq:is-non-empty $section[test-results])  {
            echo
          }
        } else {
          echo
        }

        echo (get-indentation $level)''(styled $sub-title white bold)

        var sub-section = $section[sub-sections][$sub-title]

        display-section $sub-section (+ $level 1)
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

  fn display-crashed-scripts { |crashed-scripts|
    if (seq:is-empty $crashed-scripts) {
      return
    }

    echo
    echo
    echo ⛔⛔⛔ (styled 'CRASHED SCRIPTS' bold red) ⛔⛔⛔

    keys $crashed-scripts |
      order &key=$sorting-algorithm |
      each { |crashed-script-path|
        var exception-lines = $crashed-scripts[$crashed-script-path]

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

    echo

    display-stats $summary[stats]

    display-crashed-scripts $summary[crashed-scripts]
  }
)