use str
use github.com/giancosta86/aurora-elvish/console
use github.com/giancosta86/aurora-elvish/lang

fn -print-indentation { |level|
  console:print (str:repeat ' ' (* $level 4))
}

fn -display-outcome { |test-title outcome describe-context-level|
  var is-ok = (eq $outcome $ok)
  var color = (lang:ternary $is-ok green red)
  var emoji = (lang:ternary $is-ok ✅ ❌)

  -print-indentation (+ $describe-context-level 1)
  console:echo (styled $test-title $color bold) $emoji
}

fn -display-outcome-context { |outcome-context level|
  keys  $outcome-context |
    order &key=$str:to-lower~ |
    each { |describe-title|
      var context = $outcome-context[$describe-title]

      -print-indentation $level
      console:echo (styled $describe-title white bold)

      var outcomes = $context[outcomes]

      keys $outcomes |
        order &key=$str:to-lower~ |
        each { |test-title|
          var outcome = $outcomes[$test-title]

          -display-outcome $test-title $outcome $level
        }

      -display-outcome-context $context[sub-contexts] (+ $level 1)
    }
}

fn display { |outcome-context|
  console:echo

  #TODO! Remove the section with emoji?
  console:section &emoji=📋 (styled 'Test outcomes' blue bold) {
    -display-outcome-context $outcome-context 0
  }

  console:echo
}